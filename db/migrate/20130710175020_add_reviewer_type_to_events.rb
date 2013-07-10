class AddReviewerTypeToEvents < ActiveRecord::Migration
  def change
    add_column :events, :reviewer_type, :string
  end
end
