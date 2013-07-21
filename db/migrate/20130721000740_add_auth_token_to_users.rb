class AddAuthTokenToUsers < ActiveRecord::Migration
  def change
    add_column :users, :access_token, :string
  end
end
