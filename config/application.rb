require File.expand_path('../boot', __FILE__)

# Pick the frameworks you want:
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
# require "sprockets/railtie"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

module GhcrApi
  class Application < Rails::Application

    config.autoload_paths += [ "#{config.root}/lib" ]

    config.assets.enabled = false

    config.time_zone = 'Warsaw'

    config.middleware.use Rack::MethodOverride
    config.middleware.use ActionDispatch::Cookies
    config.middleware.use ActionDispatch::Session::CookieStore
    config.middleware.use ActionDispatch::Flash

    config.middleware.use Rack::OAuth2::Server::Resource::Bearer, 'Github Commit Review API' do |req|
      AccessToken.find_by_token(req.access_token) || req.invalid_token!
    end

    config.middleware.use OmniAuth::Builder do
      provider :developer unless Rails.env.production?
      provider :github, ENV['GITHUB_CLIENT_ID'], ENV['GITHUB_CLIENT_SECRET'],
        request_path: "/api/v1/authorize", callback_path: "/api/v1/authorize/callback",
        provider_ignores_state: true, scope: 'repo user:email'
    end

    config.secret_key_base = 'ghcr-api'

    config.cache_store = :redis_store, "#{ENV['REDIS_URL'] || ENV['REDISTOGO_URL']}/ghcr-api:#{Rails.env}:cache"
  end
end
