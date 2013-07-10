class Reminder < ActiveRecord::Base
  belongs_to :user
  belongs_to :repository

  validates_inclusion_of :hour, in: 0..23

  def activate
    update_attributes(active: true)
  end

  def deactivate
    update_attributes(active: true)
  end
end
