class Event < ActiveRecord::Base
  belongs_to :reviewer, :polymorphic => true
  belongs_to :commit

  after_create :update_commit_data

  def update_commit_data
    commit.update_attributes!(:status => status, :last_reviewer => reviewer)
  end
end
