class RemindersController < ApplicationController
  before_action :find_repo
  before_action :find_reminder

  def show
    render json: { active: !!@reminder.try(:active) }
  end

  def create
    if @reminder
      @reminder.activate
    else
      current_user.reminders.create(repository: @repository)
    end
    render nothing: true
  end

  def update
    if @reminder && @reminder.update_attributes(params[:reminder])
      render status: 200
    else
      render status: 422
    end
  end

  def destroy
    if @reminder
      @reminder.deactivate
    else
      not_found
    end
    render nothing: true
  end

  private
    def find_repo
      @repository = Repository.where(owner: params[:owner], name: params[:repo]).first || not_found
    end

    def find_reminder
      @reminder = Reminder.find_by_user_and_repository(current_user, @repository)
    end

    def reminder_params
      params.require(:owner, :repo).permit(:hour)
    end
end
