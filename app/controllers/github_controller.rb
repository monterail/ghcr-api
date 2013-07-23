class GithubController < ApplicationController
  before_filter :authenticate!, :only => [:show]

  def show
    permissions = current_user.github.repository("#{params[:owner]}/#{params[:repo]}").permissions

    if repo.present?
      pending = repo.commits.query(author: "!#{current_user.username}", status: "pending")
      rejected = repo.commits.query(author: current_user.username, status: "rejected")
      connected = if permissions.admin
        current_user.github.hooks("#{repo.owner}/#{repo.name}").any? do |h|
          h.name == "web" && h.config.url == "#{ENV['URL']}/api/v1/github"
        end
      else
        repo.commits.count > 0
      end

      render json: {
        username: current_user.username,
        rejected: rejected.map(&:response_hash),
        pending: pending.map(&:response_hash),
        permissions: permissions,
        connected: connected
      }
    else
      render json: {
        username: current_user.username,
        rejected: [],
        pending: [],
        permissions: permissions,
        connected: false
      }
    end
  end

  def connect
    admin = current_user.github.repository("#{params[:owner]}/#{params[:repo]}").permissions.admin

    unless admin
      render json: { success: false, reason: "You do not have access to add Github hook for this repo" }
      return
    end

    repo = repo || Repository.create!(owner: params[:owner], name: params[:repo])

    connected = current_user.github.hooks(repo.to_s).any? do |h|
      h.name == "web" && h.config.url == "#{ENV['URL']}/api/v1/github"
    end

    unless connected
      current_user.github.create_hook repo.to_s, 'web',
        url: "#{ENV['URL']}/api/v1/github",
        content_type: 'json'
    end

    render json: { success: true }
  end

  def payload
    payload = Webhook::Payload.from_json(params[:payload] || request.body)

    attrs = {owner: payload.repository.owner.name, name: payload.repository.name}
    repo = Repository.where(attrs).first || Repository.create!(attrs)

    payload.commits.each do |commit_data|
      if commit_data.distinct
        author = User.find_or_create_from_github(commit_data.author)

        commit = repo.commits.where(sha: commit_data.id).first || repo.commits.create!({
          sha:        commit_data.id,
          message:    commit_data.message,
          author:     author,
          committer:  User.find_or_create_from_github(commit_data.committer)
        })

        status =  skip_review?(commit) ? "skipped" : "pending"
        commit.events.create!(status: status)

        # Auto accept
        accept_string = commit.message.to_s[/accepts?:?((.|\s)*)\z/].to_s
        sha_arry      = accept_string.split(/[\s;,]/).map(&:strip).uniq.select {|sha| sha =~ /^[a-z\d]{6,40}$/}

        sha_arry.each do |sha|
          if commit = repo.commits.where("sha ILIKE ?", "#{sha}%").first
            commit.events.create(status: "auto-accepted", reviewer: author)
          end
        end
      end
    end

    head :ok
  end

  private
    def skip_review?(commit)
      message = commit.message.to_s.downcase
      message[/merge/] || message[/#?(no|skip)\s?(code\s?)?review/]
    end

    def repo
      @repo ||= Repository.where(
        owner:  params[:owner],
        name:   params[:repo]
      ).first
    end
end
