source 'http://rubygems.org'
ruby '2.0.0'

gem 'rails', '4.0.2'
gem 'pg', ">= 0.17.0"
gem 'rails-api'
gem 'figaro'
gem 'yajl-ruby'

gem 'uniquify'

gem 'omniauth'
gem 'omniauth-github'
gem 'rack-oauth2', require: 'rack/oauth2'

# waiting for bump version to 2.0.1
gem 'webhook-payload', github: 'monterail/webhook-payload'
gem 'hipchat-api'
gem 'octokit', '~> 1.25'
gem 'pry-rails'
gem 'sentry-raven'
gem 'redis-rails', '~> 4.0.0'

group :development do
  # Debugging
  # gem 'pry-stack_explorer'
  # gem 'pry-debugger'
  gem 'awesome_print'

  # Testing
  gem 'rake'
  gem 'tomdoc'
  gem 'rspec-rails'
  gem 'factory_girl_rails'
  gem 'database_cleaner'
  gem 'json_spec'
end

group :production do
  gem "rails_12factor"
end
