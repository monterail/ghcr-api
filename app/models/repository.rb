class Repository < ActiveRecord::Base
  has_many :commits
end
