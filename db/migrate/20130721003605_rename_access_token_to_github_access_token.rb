class RenameAccessTokenToGithubAccessToken < ActiveRecord::Migration
  def change
    rename_column :users, :access_token, :github_access_token
  end
end
