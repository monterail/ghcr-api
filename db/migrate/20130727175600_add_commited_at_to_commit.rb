class AddCommitedAtToCommit < ActiveRecord::Migration
  def change
    add_column :commits, :commited_at, :datetime
  end
end
