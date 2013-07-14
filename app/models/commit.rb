class Commit < ActiveRecord::Base
  belongs_to :repository
  belongs_to :author, class_name: "User"
  belongs_to :committer, class_name: "User"
  belongs_to :last_reviewer, class_name: "User"
  has_many :events

  scope :pending, -> { where(status: "pending") }
  scope :rejected, -> { where(status: "rejected") }

  def self.query params
    commits = self
    any_ofs = []

    # if value starts with "!" (bang) - negation
    #
    # params[:author] == "teamon"   -> where author = 'teamon'
    # params[:author] == "!teamon"  -> where author <> 'teamon'
    [:sha, :status].reject{ |k| params[k].blank? }.each do |key|
      values = params[key].to_s.split(",")
      rejected = values.select{ |e| e =~ /^!(.+)$/ }
      accepted = values - rejected
      any_ofs << { key => accepted } unless accepted.empty?
      commits = commits.where.not(key => rejected.map{ |v| v[1..-1] })
    end

    [:author, :last_reviewer, :committer].reject{ |k| params[k].blank? }.each do |key|
      values = params[key].to_s.split(",")
      rejected = values.select{ |e| e =~ /^!(.+)$/ }
      rejected_ids = User.where(username: rejected.map{ |v| v[1..-1] }).pluck(:id)
      accepted_ids = User.where(username: values - rejected).pluck(:id)
      commits = commits.where.not("#{key}_id" => rejected_ids)
      any_ofs << { "#{key}_id" => accepted_ids } unless accepted_ids.empty?
    end

    any_ofs.empty? ? commits : commits.any_of(*any_ofs)
  end
end
