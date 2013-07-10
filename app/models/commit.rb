class Commit < ActiveRecord::Base
  belongs_to :repository
  belongs_to :author, :polymorphic => true
  belongs_to :committer, :polymorphic => true
  has_many :events

  scope :pending, -> { where(:status => "pending") }
  scope :rejected, -> { where(:status => "rejected") }
end
