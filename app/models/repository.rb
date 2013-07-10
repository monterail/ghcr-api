class Repository < ActiveRecord::Base
  has_many :commits
  has_many :reminders

  def to_s
    "#{owner}/#{name}"
  end
end
