class CreateAccessTokens < ActiveRecord::Migration
  def change
    create_table :access_tokens do |t|
      t.string :token
      t.string :scope
      t.belongs_to :user

      t.timestamps
    end
  end
end
