class GithubController < ApplicationController
  before_filter :authenticate!, :only => [:show]

  def show
    if repo.present?
      pending = repo.commits.query(author: "!#{current_user.username}", status: "pending")
      rejected = repo.commits.query(author: current_user.username, status: "rejected")

      render json: {
        username: current_user.username,
        rejected: rejected.map(&:response_hash),
        pending: pending.map(&:response_hash),
        permissions: current_user.permissions(repo_name),
        token: repo.access_token,
        connected: true
      }
    else
      render json: {
        username: current_user.username,
        rejected: [],
        pending: [],
        permissions: current_user.permissions(repo_name),
        token: "",
        connected: false
      }
    end
  end

  def connect
    unless current_user.permissions(repo_name)
      render status: :unauthorized, json: { reason: "You do not have access to add Github hook for this repo" }
      return
    end

    repo = Repository.find_or_create_by!(owner: params[:owner], name: params[:repo])
    hook_url = "#{ENV['URL']}/api/v1/github/#{repo.access_token}"

    connected = current_user.github.hooks(repo.to_s).any? do |h|
      h.name == "web" && h.config.url == hook_url
    end

    unless connected
      current_user.github.create_hook repo.to_s, 'web',
        url: hook_url,
        content_type: 'json'
      repo.update_attribute :connected, true
    end

    head :ok
  end

  def payload
    Rails.logger.info(params[:payload] || request.body.string)
    payload = Webhook::Payload.from_json(params[:payload] || request.body.string)

    repo = Repository.find_by!(access_token: params[:repository_token])

    payload.commits.each do |commit_data|
      if commit_data.distinct
        author = User.find_or_create_from_github(commit_data.author)

        commit = repo.commits.find_by(sha: commit_data.id) || repo.commits.create!({
          sha:        commit_data.id,
          ref:        payload.try(:ref),
          message:    commit_data.message,
          author:     author,
          committer:  User.find_or_create_from_github(commit_data.committer),
          commited_at:commit_data.timestamp
        })

        commit.extend(MessageAnalyzer)

        status = commit.skip_review? ? "skipped" : "pending"
        commit.events.create!(status: status)

        commit.accepted_shas.each do |sha|
          if c = repo.commits.find_by_sha(sha)
            c.events.create(:status => "auto-accepted", :reviewer => author)
          end
        end
      end
    end

    head :ok
  end

  protected

  def repo
    @repo ||= Repository.find_by(full_name: repo_name)
  end

  def repo_name
    "#{params[:owner]}/#{params[:repo]}"
  end

end
