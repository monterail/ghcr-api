class RemindersController < ApplicationController
  def show
    render json: { active: !!reminder.try(:active) }
  end

  def create
    if reminder
      reminder.activate
    else
      current_user.reminders.create(repository: repository)
    end
    render nothing: true
  end

  def update
    if reminder && reminder.update_attributes(reminder_params)
      render nothing: true
    else
      head :unprocessable_entity
    end
  end

  def destroy
    if reminder
      reminder.deactivate
    else
      not_found
    end
    render nothing: true
  end

  private
    def repository
      @repository ||= Repository.where(owner: params[:owner], name: params[:repo]).first || not_found
    end

    def reminder
      @reminder ||= Reminder.find_by_user_and_repository(current_user, repository)
    end

    def reminder_params
      params.require(:reminder).permit(:hour)
    end
end
