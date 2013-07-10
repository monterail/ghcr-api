class Event < ActiveRecord::Base
  belongs_to :reviewer, :class_name => "User"
  belongs_to :commit

  after_create :update_commit_data

  def update_commit_data
    commit.update_attributes!(:status => status, :last_reviewer_id => reviewer_id)
  end
end
