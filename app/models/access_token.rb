class AccessToken < ActiveRecord::Base
  belongs_to :user

  before_create do
    self.token = SecureRandom.urlsafe_base64(nil, false)
  end
end
