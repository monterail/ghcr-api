class StatsController < ApplicationController
  def show
    shas = params[:repos].to_s.split(',')
    repos = Repository.where(:access_token => shas).pluck(:id, :name)
    chain_start = Commit.where(:repository_id => repos.map(&:first))
    render json: {
      pending:  chain_start.pending.count,
      rejected: chain_start.rejected.count,
      pending_per_project: per_repo_count(chain_start.pending, repos),
      rejected_per_project: per_repo_count(chain_start.rejected, repos)
    }
  end

  private
    def per_repo_count query, repos
      counts = Hash[query.count(group: :repository_id)]
      Hash[repos.map do |r_id, name|
        [name, counts[r_id].to_i]
      end]
    end
end
