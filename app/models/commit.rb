class Commit < ActiveRecord::Base
  belongs_to :repository
  belongs_to :author, :class_name => "User"
  belongs_to :committer, :class_name => "User"
  belongs_to :last_reviewer, :class_name => "User"
  has_many :events

  scope :pending, -> { where(:status => "pending") }
  scope :rejected, -> { where(:status => "rejected") }
end
