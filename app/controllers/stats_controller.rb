class StatsController < ApplicationController
  def show
    shas = params[:repos].to_s.split(',')
    repos = if shas.present?
      Repository.where(:access_token => shas).pluck(:id, :full_name)
    else
      Repository.pluck(:id, :full_name)
    end
    chain_start = Commit.where(:repository_id => repos.map(&:first))
    render json: {
      pending:  chain_start.pending.count,
      discuss: chain_start.discuss.count,
      pending_per_project: per_repo_count(chain_start.pending, repos),
      discuss_per_project: per_repo_count(chain_start.discuss, repos),
      pending_per_author: per_author_count(chain_start.pending),
      discuss_per_author: per_author_count(chain_start.discuss),
      pending_overall: overall(chain_start.pending, repos),
      discuss_overall: overall(chain_start.discuss, repos)
    }
  end

  private
    def overall(query, repos)
      counts = Hash[query.count(group: :repository_id)]
      result = repos.map do |r_id, name|
        [name, per_author_count(query.where(repository_id: r_id))] if counts[r_id]
      end.compact.sort {|a, b| b[1].values.sum <=> a[1].values.sum }
      Hash[result]
    end

    def per_repo_count(query, repos)
      counts = Hash[query.count(group: :repository_id)]
      result = repos.map do |r_id, name|
        [name, counts[r_id].to_i] if counts[r_id]
      end.compact.sort {|a, b| b[1] <=> a[1] }
      Hash[result]
    end

    def per_author_count(query)
      counts = Hash[query.count(group: :author_id)]
      result = counts.map do |author_id, count|
        [User.find(author_id).name, count.to_i]
      end.compact.sort {|a, b| b[1] <=> a[1] }
      Hash[result]
    end
end
