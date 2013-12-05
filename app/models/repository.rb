class Repository < ActiveRecord::Base
  has_many :commits
  has_many :reminders

  uniquify :access_token, :length => 10

  def next_pending sha = nil
    query = commits.pending.order("commited_at ASC")
    if sha && commit = Commit.find_by_sha(sha)
      query = query.where(["commited_at > ?", commit.commited_at])
    end
    query.first
  end

  def to_s
    "#{owner}/#{name}"
  end
end
