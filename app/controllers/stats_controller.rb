class StatsController < ApplicationController
  before_filter :authenticate!, only: :commits

  def show
    render json: Statistic.new(params[:repos])
  end

  def commits
    params.reverse_merge!(author: current_user.username, status: 'discuss')
    render json: Commit.query(params).order('commited_at DESC').limit(100).map(&:response_hash)
  end
end
