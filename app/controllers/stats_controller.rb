class StatsController < ApplicationController
  def index
    render :json => {
      :pending  => Commit.pending.count,
      :rejected => Commit.rejected.count,
      :pending_per_project => per_repo_count(Commit.pending),
      :rejected_per_project => per_repo_count(Commit.rejected)
    }
  end

  private
    def per_repo_count query
      counts = query.count(:group => :repository_id)
      repos = Repository.find(counts.keys).inject({}) do |memo,e|
        memo.tap{ |m| m[e.id] = e }
      end
      Hash[counts.to_a.map do |r_id, count|
        [repos[r_id], count]
      end]
    end
end
