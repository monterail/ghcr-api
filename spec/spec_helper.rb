# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'

require 'factory_girl_rails'
require 'database_cleaner'
require 'json_spec'
Dir["./spec/support/**/*.rb"].sort.each{|f| require(f)}

$:<< File.join(File.dirname(__FILE__))

ActiveRecord::Migration.check_pending! if defined?(ActiveRecord::Migration)
OmniAuth.config.test_mode = true

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
  config.include OmniauthMacros
  config.include JsonSpec::Helpers

  config.infer_base_class_for_anonymous_controllers = true

  config.order = "random"

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  def fixture(file)
    File.read(File.join(File.dirname(__FILE__), 'fixtures', file))
  end
end
