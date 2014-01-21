class UsersController < ApplicationController
  before_filter :authenticate!

  def show
    user_repositories = Rails.cache.fetch("user_repositories_#{current_user.id}", expires_in: 1.hour) do
      current_user.github.repositories +
      current_user.github.organizations.map do |org|
        current_user.github.org_repos(org.login)
      end.flatten(1)
    end

    keys = user_repositories.map { |repo| "#{repo.owner.login}/#{repo.name}" }
    ghcr_repos = Repository.where(full_name: keys).to_a.inject({}){ |h, r| h[r.to_s] = r; h }

    normalized_repositories = user_repositories.map do |repo|
      ghcr_repo = ghcr_repos["#{repo.owner.login}/#{repo.name}"]

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
