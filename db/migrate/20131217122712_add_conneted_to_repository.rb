class AddConnetedToRepository < ActiveRecord::Migration
  def change
    add_column :repositories, :connected, :boolean, default: false
  end
end
