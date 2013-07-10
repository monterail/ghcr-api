class CreateReminders < ActiveRecord::Migration
  def change
    create_table :reminders do |t|
      t.integer :hour,    default: 11
      t.boolean :active,  default: true
      t.references :user
      t.references :repository

      t.timestamps
    end
  end
end
