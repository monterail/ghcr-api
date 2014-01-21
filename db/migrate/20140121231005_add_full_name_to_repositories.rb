class AddFullNameToRepositories < ActiveRecord::Migration
  def change
    add_column :repositories, :full_name, :string
  end
end
