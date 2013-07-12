class CommitsController < ApplicationController
  before_filter :authenticate!

  def index
    commits = repo.commits

    # if value starts with "!" (bang) - negation
    #
    # params[:author] == "teamon"   -> where author = 'teamon'
    # params[:author] == "!teamon"  -> where author <> 'teamon'
    [:sha, :status].each do |key| # TODO: author,last_reviewer
      unless params[key].blank?
        params[key].to_s.split(",").each do |e|
          if e =~ /^!(.+)$/
            commits = commits.where("#{key} <> ?", $1)
          else
            commits = commits.where(key => e)
          end
        end
      end
    end

    render :json => commits
  end

  def show
    commit = repo.commits.where(:sha => params[:sha]).first || not_found
    render :json => commit
  end

  def update
    sha = params[:id]
    commit = repo.commits.where(:sha => sha).first
    commit ||= repo.commits.create!(
      :sha        => params[:id],
      :message    => params[:message],
      :author     => User.get_user_or_ghost(params[:author]),
      :committer  => User.get_user_or_ghost(params[:committer])
    )

    event = commit.events.create!(
      :status   => params[:status],
      :reviewer => current_user
    )

    Notification.deliver_rejected(event) if event.status == "rejected"

    render :json => commit
  end

  protected


  def current_user
    User.first || User.create(:username => "teamon")
  end


  def repo
    @repo ||= Repository.where(
      :owner  => params[:owner],
      :name   => params[:repo]
    ).first || not_found
  end

  def not_found
    raise ActiveRecord::RecordNotFound
  end
end
