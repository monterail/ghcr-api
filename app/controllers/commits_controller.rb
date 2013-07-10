class CommitsController < ApplicationController
  def index
    commits = repo.commits

    # if value starts with "!" (bang) - negation
    #
    # params[:author] == "teamon"   -> where author = 'teamon'
    # params[:author] == "!teamon"  -> where author <> 'teamon'
    [:sha, :author, :status].each do |key|
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

    render :json => commits.to_json
  end

  def show
    commit = repo.commits.where(:sha => params[:sha]).first || not_found
    render :json => commit
  end

  protected

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
