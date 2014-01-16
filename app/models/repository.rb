class Repository < ActiveRecord::Base
  has_many :commits
  has_many :reminders

  uniquify :access_token, :length => 10

  class << self
    def with_access_by(username, access_type = :admin)
      user = User.find_by!(username: username)
      Repository.all.select do |repo|
        access = begin
          user.permissions(repo.to_s).try(access_type)
        rescue Octokit::NotFound => ex
          false
        end
        !!access
      end
    end
  end

  def next_pending sha = nil, current_user = nil
    query = commits.pending.order("commited_at ASC")
    query = query.where("committer_id != ?", current_user.id) if current_user
    next_commit = if sha && commit = Commit.find_by_sha(sha)
      query.where(["commited_at > ?", commit.commited_at]).first
    end
    next_commit || query.first
  end

  def to_s
    "#{owner}/#{name}"
  end
end
