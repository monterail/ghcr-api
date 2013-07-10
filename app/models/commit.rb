class Commit < ActiveRecord::Base
  belongs_to :repository

  scope :pending, where(:status => "pending")
  scope :rejected, where(:status => "rejected")
end
