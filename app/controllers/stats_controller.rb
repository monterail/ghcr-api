class StatsController < ApplicationController
  def show
    render json: Statistic.new(params[:repos])
  end
end
