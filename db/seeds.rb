# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)



repo = Repository.create!(:owner => "monterail", :name => "ghcr-web")
repo.commits.create!(
  :sha => "8f5ff5b4f09250a2dd620fbb75edc20d7fec3eaa",
  :message => "Commits controller",
  :status => "pending",
  :author => "teamon"
)

repo.commits.create!(
  :sha => "ed17c65499701fc6d198b6ccef2e59a71ec1b60e",
  :message => "Add omniauth and debug tools to Gemfile",
  :status => "rejected",
  :author => "sheerun"
)

repo.commits.create!(
  :sha => "a36ab33c27ccfd33631d79349d8dccfde613b365",
  :message => "basic models",
  :status => "accepted",
  :author => "teamon"
)
