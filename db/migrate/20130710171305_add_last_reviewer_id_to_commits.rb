class AddLastReviewerIdToCommits < ActiveRecord::Migration
  def change
    add_column :commits, :last_reviewer_id, :integer
  end
end
