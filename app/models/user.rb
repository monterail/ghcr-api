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
    Octokit::Client.new(:login => username, :oauth_token => github_access_token)
  end
end
