class AddHipchatUsernameToUsers < ActiveRecord::Migration
  def change
    add_column :users, :hipchat_username, :string
  end
end
