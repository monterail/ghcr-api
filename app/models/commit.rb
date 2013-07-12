class Commit < ActiveRecord::Base
  belongs_to :repository
  belongs_to :author
  belongs_to :committer
  belongs_to :last_reviewer
  has_many :events

  scope :pending, -> { where(:status => "pending") }
  scope :rejected, -> { where(:status => "rejected") }
end
