class User < ActiveRecord::Base
  has_many :access_tokens, dependent: :delete_all
  has_many :reminders, dependent: :delete_all

  has_many :authored_commits, class_name: 'Commit', foreign_key: 'author_id'
  has_many :commited_commits, class_name: 'Commit', foreign_key: 'commiter_id'
  has_many :reviewed_commits, class_name: 'Commit', foreign_key: 'last_reviewer_id'

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

  def hipchat_username
    return @hipchat_username if defined? @hipchat_username
    @hipchat_username = (hipchat_username? ? read_attribute(:hipchat_username) : username)
  end

  def access_token
    access_tokens.first || access_tokens.create
  end

  def github
    Octokit::Client.new(:login => username, :oauth_token => github_access_token, :auto_traversal => true)
  end

  def permissions(repo_name)
    github.repository(repo_name).permissions
  end

  def team_member?
    return true if Figaro.env.github_org.blank?
    team_members = Octokit.org_members(Figaro.env.github_org).map{ |m| m['login'] }
    team_members += Figaro.env.guest_members.split(',')
    team_members.include?(username)
  end
end
