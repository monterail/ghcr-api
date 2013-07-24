class StatsController < ApplicationController
  def show
    shas = params[:repos].to_s.split(',')
    repos = Repository.where(:access_token => shas).pluck(&:id)
    chain_start = Commit.where(:repository_id => repos.map(&:id))
    render json: {
      pending:  chain_start.pending.count,
      rejected: chain_start.rejected.count,
      pending_per_project: per_repo_count(chain_start.pending),
      rejected_per_project: per_repo_count(chain_start.rejected)
    }
  end

  private
    def per_repo_count query
      counts = query.count(group: :repository_id)
      repos = Repository.find(counts.keys).inject({}) do |memo,e|
        memo.tap{ |m| m[e.id] = e }
      end
      Hash[counts.to_a.map do |r_id, count|
        [repos[r_id], count]
      end]
    end
end
