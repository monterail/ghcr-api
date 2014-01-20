class User < ActiveRecord::Base
  has_many :access_tokens, dependent: :delete_all
  has_many :reminders, dependent: :delete_all

  # Public: Find or create user from github payload
  #
  # data - user hash returned from github
  #        :email - github user email (required)
  #        :name - github user name (required)
  #        :username - github user login (optional)
  def self.find_or_create_from_github(data)
    user = if data[:username].present?
      find_or_create_by(username: data[:username])
    else
      find_or_create_by(email: data[:email])
    end

    user.name  ||= data[:name]
    user.email ||= data[:email]

    user.save! if user.changed?
    user
  end

  def access_token
    access_tokens.first || access_tokens.create
  end

  def github
    Octokit::Client.new(:login => username, :oauth_token => github_access_token, :auto_traversal => true)
  end

  def permissions(repo_name)
    Rails.cache.fetch("user_permissions_#{id}_#{repo_name}", expires_in: 1.day) do
      github.repository(repo_name).permissions
    end
  end

  def team_member?
    return true if Figaro.env.github_org.blank?
    team_members = Rails.cache.fetch("team_members", expires_in: 1.day) do
      github.org_members(Figaro.env.github_org).map{ |m| m['login'] }
    end
    team_members.include?(username)
  end
end
