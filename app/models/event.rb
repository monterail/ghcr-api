class Event < ActiveRecord::Base
  belongs_to :commit
  belongs_to :reviewer, class_name: "User"

  after_create :update_commit_data

  def update_commit_data
    commit.update_attributes!(status: status, last_reviewer: reviewer)
  end

  def response_hash
    {
      commit_id: commit.sha,
      status: status,
      reviewer: {
        username: reviewer.try(:username),
        name: reviewer.try(:name)
      },
      created_at: created_at
    }
  end
end
