class Commit < ActiveRecord::Base
  belongs_to :repository
  belongs_to :author, class_name: "User"
  belongs_to :committer, class_name: "User"
  belongs_to :last_reviewer, class_name: "User"
  has_many :events, dependent: :delete_all

  scope :pending, -> { where(status: "pending") }
  scope :discuss, -> { where(status: "discuss") }

  def self.find_by_sha(sha)
    where("sha ILIKE ?", "#{sha}%").first
  end

  def self.query params
    commits = self

    # if value starts with "!" (bang) - negation
    #
    # params[:author] == "teamon,darek"   -> where(author: ['teamon','darek'])
    # params[:author] == "!teamon,darek"  -> where.not(author: ['teamon','darek'])
    [:sha, :status].reject{ |k| params[k].blank? }.each do |key|
      values = params[key].to_s.split(",")
      if values.first =~ /^!(.+)$/
        values.first[0] = ''
        commits = commits.where.not(key => values)
      else
        commits = commits.where(key => values)
      end
    end

    [:author, :last_reviewer, :committer].reject{ |k| params[k].blank? }.each do |key|
      values = params[key].to_s.split(",")
      if values.first =~ /^!(.+)$/
        values.first[0] = ''
        discuss_ids = User.where(username: values).pluck(:id)
        commits = commits.where.not("#{key}_id" => discuss_ids)
      else
        accepted_ids = User.where(username: values).pluck(:id)
        commits = commits.where("#{key}_id" => accepted_ids)
      end
    end

    commits
  end

  def response_hash
    {
      id: sha,
      message: message,
      timestamp: created_at,
      status: status,
      last_event: events.last.try(:response_hash),
      author: {
        username: author.try(:username),
        name:     author.try(:name)
      }
    }
  end
end
