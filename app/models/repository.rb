class Repository < ActiveRecord::Base
  has_many :commits
  has_many :reminders

  uniquify :access_token, :length => 10

  def to_s
    "#{owner}/#{name}"
  end
end
