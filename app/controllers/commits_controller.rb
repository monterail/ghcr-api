class CommitsController < ApplicationController
  before_filter :authenticate!

  def index
    render json: repo.commits.query(params).order('commited_at DESC').limit(100).map(&:response_hash)
  end

  def count
    render json: { count: repo.commits.query(params).count }
  end

  def show
    commit = repo.commits.find_by(sha: params[:id]) || not_found
    render json: commit.response_hash
  end

  def next
    commit = repo.next_pending(params[:id], current_user)
    if request.xhr?
      render json: { id: commit.try(:sha) }
    else
      redirect_to "//github.com/#{repo.to_s}#{"/commit/#{commit.sha}" if commit.present?}"
    end
  end

  def update
    sha = params[:id]
    commit = repo.commits.find_by(sha: sha)
    commit ||= repo.commits.create!(
      sha:        params[:id],
      message:    params[:message],
      author:     User.find_or_create_from_github(params[:author]),
      committer:  User.find_or_create_from_github(params[:committer])
    )

    if commit.author == current_user
      head :unauthorized
      return
    end

    event = commit.events.create!(
      status:   params[:status],
      reviewer: current_user
    )

    Notification.deliver_rejected(event) if event.status == "rejected"

    render json: commit.reload.response_hash
  end

  protected

  def repo
    @repo ||= Repository.find_by(full_name: repo_full_name) || not_found
  end

  def repo_full_name
    "#{params[:owner]}/#{params[:repo]}"
  end
end
