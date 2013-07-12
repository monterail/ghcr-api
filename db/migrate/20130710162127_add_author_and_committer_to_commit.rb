class AddAuthorAndCommitterToCommit < ActiveRecord::Migration
  def change
    add_column :commits, :author_id, :integer
    add_column :commits, :committer_id, :integer
    remove_column :commits, :author, :string
  end
end
