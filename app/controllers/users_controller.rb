class UsersController < ApplicationController
  before_filter :authenticate!

  def show
    user_repositories =
      current_user.github.repositories +
      current_user.github.organizations.map { |org|
        current_user.github.org_repos(org.login)
      }.flatten(1)

    normalized_repositories = user_repositories.map do |repo|
      ghcr_repo = Repository.where(owner: repo.owner.login, name: repo.name).first

      pending = ghcr_repo ?
        ghcr_repo.commits.query(author: "!#{current_user.username}", status: "pending").count : 0

      rejected = ghcr_repo ?
        ghcr_repo.commits.query(author: current_user.username, status: "rejected").count : 0

      {
        name: repo.name,
        owner: repo.owner.login,
        full_name: repo.full_name,
        private: repo.private,
        url: repo.url,
        html_url: repo.html_url,
        permissions: repo.permissions,
        connected: !!ghcr_repo.try(:connected),
        pending_count: pending,
        rejected_count: rejected
      }
    end

    render json: {
      username: current_user.username,
      hipchat_username: current_user.hipchat_username,
      repositories: normalized_repositories
    }
  end

  def update
    current_user.update_attributes!(user_settings)
    head :ok
  end

  protected

  def user_settings
    params[:users].slice(:hipchat_username)
  end
end
