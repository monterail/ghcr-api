class AddAccessTokenToRepository < ActiveRecord::Migration
  def change
    add_column :repositories, :access_token, :string
  end
end
