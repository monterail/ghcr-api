class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.integer :commit_id, index: true
      t.integer :reviewer_id, index: true
      t.string :status

      t.timestamps
    end
  end
end
