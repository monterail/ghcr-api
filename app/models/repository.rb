class Repository < ActiveRecord::Base
  has_many :commits

  def to_s
    "#{owner}/#{name}"
  end
end
