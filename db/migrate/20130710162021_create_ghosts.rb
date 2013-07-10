class CreateGhosts < ActiveRecord::Migration
  def change
    create_table :ghosts do |t|
      t.string :name
      t.string :email

      t.timestamps
    end
  end
end
