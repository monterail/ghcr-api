class AddMissingIndexes < ActiveRecord::Migration
  def change
    add_index :access_tokens, :user_id
    add_index :access_tokens, :token

    add_index :commits, :repository_id
    add_index :commits, :committer_id
    add_index :commits, :last_reviewer_id
    add_index :commits, :sha
    add_index :commits, [:status, :author_id]

    add_index :events, :commit_id
    add_index :events, :reviewer_id

    add_index :reminders, :user_id
    add_index :reminders, :repository_id

    add_index :users, :username
    add_index :repositories, :full_name
    add_index :repositories, :access_token
  end
end
