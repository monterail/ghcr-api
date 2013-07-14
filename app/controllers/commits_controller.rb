class CommitsController < ApplicationController
  before_filter :authenticate!

  def index
    commits = repo.commits
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

    render json: any_ofs.empty? ? commits : commits.any_of(*any_ofs)
  end

  def show
    commit = repo.commits.where(sha: params[:sha]).first || not_found
    render json: commit
  end

  def update
    sha = params[:id]
    commit = repo.commits.where(sha: sha).first
    commit ||= repo.commits.create!(
      sha:        params[:id],
      message:    params[:message],
      author:     User.find_or_create_from_github(params[:author]),
      committer:  User.find_or_create_from_github(params[:committer])
    )

    event = commit.events.create!(
      status:   params[:status],
      reviewer: current_user
    )

    Notification.deliver_rejected(event) if event.status == "rejected"

    render json: commit
  end

  protected

  def repo
    @repo ||= Repository.where(
      owner:  params[:owner],
      name:   params[:repo]
    ).first || not_found
  end
end
