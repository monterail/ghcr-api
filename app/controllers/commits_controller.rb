class CommitsController < ApplicationController
  def index
    @commits = Commit.all
    render :json => @commits.to_json
  end

  def show
    @commit = Commit.find_by_sha(params[:sha])
    render :json => @commit
  end
end
