class CreateCommits < ActiveRecord::Migration
  def change
    create_table :commits do |t|
      t.string :sha
      t.string :status
      t.text :message
      t.string :author
      t.integer :repository_id

      t.timestamps
    end
  end
end
