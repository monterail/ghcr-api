# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

GhcrWeb::Application.load_tasks

require 'rake/testtask'

Rake::TestTask.new do |t|
    t.libs << "app"
    t.libs << "spec"
    t.pattern = "spec/**/*_spec.rb"
    t.verbose = true
end

task :default => [:test]
