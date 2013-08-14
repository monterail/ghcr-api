class UsersController < ApplicationController
  before_filter :authenticate!, :only => [:show]

  def show
    render json: {
      repositories: current_user.github.repositories
    }
  end

end
