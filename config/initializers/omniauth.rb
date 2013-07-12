OmniAuth.configure do |config|
  config.logger = Rails.logger
  config.path_prefix = '/api/v1/authorize'
end
