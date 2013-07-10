class Event < ActiveRecord::Base
  belongs_to :reviewer, :class_name => "User"
  belongs_to :commit
end
