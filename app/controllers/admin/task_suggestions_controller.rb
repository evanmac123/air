class Admin::TaskSuggestionsController < AdminBaseController

  def update
    task_suggestion = TaskSuggestion.find(params[:id], :include => :task)
    task_suggestion.satisfy!
    flash[:success] = "#{task_suggestion.task.name} manually completed for #{task_suggestion.user.name}"
    redirect_to :back
  end
end
