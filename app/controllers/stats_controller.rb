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
      pending_per_project: per_repo_count(chain_start.pending),
      discuss_per_project: per_repo_count(chain_start.discuss),
      pending_per_author: per_author_count(chain_start.pending),
      discuss_per_author: per_author_count(chain_start.discuss),
      pending_overall_per_project: overall_per_repo(chain_start.pending),
      discuss_overall_per_project: overall_per_repo(chain_start.discuss),
      pending_overall_per_author: overall_per_author(chain_start.pending),
      discuss_overall_per_author: overall_per_author(chain_start.discuss),
    }
  end

  private
    def overall_per_repo(query)
      counts = Hash[query.count(group: :repository_id)]
      result = counts.map do |r_id, count|
        [
          Repository.find(r_id).full_name,
          per_author_count(query.where(repository_id: r_id))
        ]
      end.compact.sort {|a, b| b[1].values.sum <=> a[1].values.sum }
      Hash[result]
    end

    def overall_per_author(query)
      counts = Hash[query.count(group: :author_id)]
      result = counts.map do |author_id, count|
        [
          User.find(author_id).name,
          per_repo_count(query.where(author_id: author_id))
        ]
      end.compact.sort {|a, b| b[1].values.sum <=> a[1].values.sum }
      Hash[result]
    end

    def per_repo_count(query)
      counts = Hash[query.count(group: :repository_id)]
      result = counts.map do |r_id, count|
        [
          Repository.find(r_id).full_name,
          count.to_i
        ]
      end.compact.sort {|a, b| b[1] <=> a[1] }
      Hash[result]
    end

    def per_author_count(query)
      counts = Hash[query.count(group: :author_id)]
      result = counts.map do |author_id, count|
        [
          User.find(author_id).name,
          count.to_i
        ]
      end.compact.sort {|a, b| b[1] <=> a[1] }
      Hash[result]
    end
end
