class CommitsController < ApplicationController
  def index
    @commits = repo.commits.all
    render :json => @commits.to_json
  end

  def show
    @commit = repo.commits.where(:sha => params[:sha]).first || not_found
    render :json => @commit
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
