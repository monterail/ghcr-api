class UsersController < ApplicationController
  before_filter :authenticate!, :only => [:show]

  def show
    user_repositories = Rails.cache.fetch("user_repositories_#{current_user.id}", expires_in: 1.hour) do
      current_user.github.repositories +
      current_user.github.organizations.map do |org|
        current_user.github.org_repos(org.login)
      end.flatten(1)
    end

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
        permissions: repo.permissions,
        connected: !!ghcr_repo.try(:connected),
        pending_count: pending,
        rejected_count: rejected
      }
    end

    render json: {
      username: current_user.username,
      repositories: normalized_repositories
    }
  end

end
