# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20140121232450) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "access_tokens", force: true do |t|
    t.string   "token"
    t.string   "scope"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "access_tokens", ["token"], name: "index_access_tokens_on_token", using: :btree
  add_index "access_tokens", ["user_id"], name: "index_access_tokens_on_user_id", using: :btree

  create_table "commits", force: true do |t|
    t.string   "sha"
    t.string   "status"
    t.text     "message"
    t.integer  "repository_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "author_id"
    t.integer  "committer_id"
    t.integer  "last_reviewer_id"
    t.datetime "commited_at"
    t.string   "ref"
  end

  add_index "commits", ["committer_id"], name: "index_commits_on_committer_id", using: :btree
  add_index "commits", ["last_reviewer_id"], name: "index_commits_on_last_reviewer_id", using: :btree
  add_index "commits", ["repository_id"], name: "index_commits_on_repository_id", using: :btree
  add_index "commits", ["sha"], name: "index_commits_on_sha", using: :btree
  add_index "commits", ["status", "author_id"], name: "index_commits_on_status_and_author_id", using: :btree

  create_table "events", force: true do |t|
    t.integer  "commit_id"
    t.integer  "reviewer_id"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "events", ["commit_id"], name: "index_events_on_commit_id", using: :btree
  add_index "events", ["reviewer_id"], name: "index_events_on_reviewer_id", using: :btree

  create_table "reminders", force: true do |t|
    t.integer  "hour",          default: 11
    t.boolean  "active",        default: true
    t.integer  "user_id"
    t.integer  "repository_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "reminders", ["repository_id"], name: "index_reminders_on_repository_id", using: :btree
  add_index "reminders", ["user_id"], name: "index_reminders_on_user_id", using: :btree

  create_table "repositories", force: true do |t|
    t.string   "name"
    t.string   "owner"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "access_token"
    t.boolean  "connected",    default: false
    t.string   "full_name"
  end

  add_index "repositories", ["access_token"], name: "index_repositories_on_access_token", using: :btree
  add_index "repositories", ["full_name"], name: "index_repositories_on_full_name", using: :btree

  create_table "users", force: true do |t|
    t.string   "name"
    t.string   "username"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "github_access_token"
    t.string   "hipchat_username"
  end

  add_index "users", ["username"], name: "index_users_on_username", using: :btree

end
