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
    user = User.where(email: data[:email]).first ||
           User.new(email: data[:email])

    if user.name != data[:name]
      user.name = data[:name]
    end

    if data[:username] && user.username != data[:username]
      user.username = data[:username]
    end

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

  # now this is the simplest and the fastest way to do it
  def monterail_member?
    Notification::HARDCODED_MAPPING.keys.include?(username.to_s.downcase)
  end
end
