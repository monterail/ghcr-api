class AddRefToCommit < ActiveRecord::Migration
  def change
    add_column :commits, :ref, :string
  end
end
