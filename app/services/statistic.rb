class Statistic

  def initialize(shas = nil)
    shas = shas.to_s.split(',')
    @query_chain = if shas.present?
      Commit.where(repository_id: Repository.where(access_token: shas).pluck(:id))
    else
      Commit
    end
  end

  def to_hash
    result = {}
    [:pending, :discuss].each do |state|
      query = @query_chain.send(state)
      result[state] = {
        count:                query.count,
        per_project:          per_repo_count(query),
        per_author:           per_author_count(query),
        overall_per_project:  overall_per_repo(query),
        overall_per_author:   overall_per_author(query)
      }
    end
    result
  end

  def overall_per_repo(query)
    counts = Hash[query.group(:repository_id).count]
    result = counts.map do |r_id, count|
      [
        Repository.find(r_id).full_name,
        per_author_count(query.where(repository_id: r_id))
      ]
    end.compact.sort {|a, b| b[1].values.sum <=> a[1].values.sum }
    Hash[result]
  end

  def overall_per_author(query)
    counts = Hash[query.group(:author_id).count]
    result = counts.map do |author_id, count|
      [
        User.find(author_id).name,
        per_repo_count(query.where(author_id: author_id))
      ]
    end.compact.sort {|a, b| b[1].values.sum <=> a[1].values.sum }
    Hash[result]
  end

  def per_repo_count(query)
    counts = Hash[query.group(:repository_id).count]
    result = counts.map do |r_id, count|
      [
        Repository.find(r_id).full_name,
        count.to_i
      ]
    end.compact.sort {|a, b| b[1] <=> a[1] }
    Hash[result]
  end

  def per_author_count(query)
    counts = Hash[query.group(:author_id).count]
    result = counts.map do |author_id, count|
      [
        User.find(author_id).name,
        count.to_i
      ]
    end.compact.sort {|a, b| b[1] <=> a[1] }
    Hash[result]
  end
end
