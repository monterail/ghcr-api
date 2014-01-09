require 'raven'

Raven.configure do |config|
  config.dsn = Figaro.env.raven_dsn
  config.tags = { environment: Rails.env }
  config.current_environment = Rails.env
end
