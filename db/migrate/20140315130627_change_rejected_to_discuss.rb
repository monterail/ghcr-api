class ChangeRejectedToDiscuss < ActiveRecord::Migration
  def up
    [Event, Commit].each do |model|
      model.where(status: 'rejected').update_all(status: 'discuss')
    end
  end

  def down
    [Event, Commit].each do |model|
      model.where(status: 'discuss').update_all(status: 'rejected')
    end
  end
end
