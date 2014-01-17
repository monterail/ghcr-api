class StatsController < ApplicationController
  def show
    shas = params[:repos].to_s.split(',')
    repos = if shas.present?
      Repository.where(:access_token => shas).pluck(:id, :name)
    else
      repository_ids = Commit.pending.group(:repository_id).having('COUNT(*) > 0').count.keys
      Repository.where(:id => repository_ids).pluck(:id, :name)
    end
    chain_start = Commit.where(:repository_id => repos.map(&:first))
    render json: {
      pending:  chain_start.pending.count,
      rejected: chain_start.rejected.count,
      pending_per_project: per_repo_count(chain_start.pending, repos),
      rejected_per_project: per_repo_count(chain_start.rejected, repos),
      pending_per_author: per_author_count(chain_start.pending),
      rejected_per_author: per_author_count(chain_start.rejected)
    }
  end

  private
    def per_repo_count(query, repos)
      counts = Hash[query.count(group: :repository_id)]
      Hash[repos.map do |r_id, name|
        [name, counts[r_id].to_i]
      end]
    end

    def per_author_count(query)
      counts = Hash[query.count(group: :author_id)]
      Hash[counts.map do |author_id, count|
        [User.find(author_id).name, count.to_i]
      end]
    end
end
