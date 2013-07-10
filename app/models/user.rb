class User < ActiveRecord::Base
  has_many :access_tokens

  def self.get_user_or_ghost(data)
    return nil if data.blank?
    User.where(:username => data[:username]).first ||
    Ghost.where(:email => data[:email]) ||
    Ghost.create!(data)
  end
end
