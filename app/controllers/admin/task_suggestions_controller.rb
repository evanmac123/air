class Admin::TaskSuggestionsController < AdminBaseController

  def update
    task_suggestion = TaskSuggestion.find(params[:id], :include => :suggested_task)
    task_suggestion.satisfy!
    flash[:success] = "#{task_suggestion.suggested_task.name} manually completed for #{task_suggestion.user.name}"
    redirect_to :back
  end
end
