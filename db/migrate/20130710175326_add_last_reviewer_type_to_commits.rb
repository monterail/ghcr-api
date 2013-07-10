class AddLastReviewerTypeToCommits < ActiveRecord::Migration
  def change
    add_column :commits, :last_reviewer_type, :string
  end
end
