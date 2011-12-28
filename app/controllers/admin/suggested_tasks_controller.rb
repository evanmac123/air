class Admin::SuggestedTasksController < AdminBaseController
  before_filter :find_demo_by_demo_id
  before_filter :find_suggested_task, :only => [:edit, :update]

  def index
    @suggested_tasks = @demo.suggested_tasks.alphabetical.includes(:prerequisites).includes(:rule_triggers)
  end

  def new
    @suggested_task = @demo.suggested_tasks.new
    @surveys = @demo.surveys
    @existing_tasks = find_existing_tasks(@demo)
    @primary_values = RuleValue.visible_from_demo(@demo).primary.alphabetical
  end

  def create
    @suggested_task = @demo.suggested_tasks.build(params[:suggested_task])
    @suggested_task.save!

    set_up_completion_triggers

    flash[:success] = "New suggested task created"
    redirect_to :action => :index
  end

  def edit
    @existing_tasks = find_existing_tasks(@demo) - [@suggested_task] # no circular dependencies kthx
    @surveys = @demo.surveys
    @primary_values = RuleValue.visible_from_demo(@demo).primary.alphabetical
    @selected_rule_ids = @suggested_task.rule_triggers.map(&:rule_id)
    @selected_survey_id = @suggested_task.survey_trigger.try(:survey_id)
  end

  def update
    @suggested_task.attributes = params[:suggested_task]
    @suggested_task.save!
    set_up_completion_triggers

    flash[:success] = "Suggested task updated"
    redirect_to :action => :index
  end

  protected
  
  def find_suggested_task
    @suggested_task = SuggestedTask.find(params[:id])
  end

  def find_existing_tasks(demo)
    @demo.suggested_tasks.alphabetical  
  end

  def set_up_completion_triggers
    return unless params[:completion].present?

    set_up_rule_triggers(params[:completion][:rule_ids])
    set_up_survey_trigger(params[:completion][:survey_id])
  end

  def set_up_rule_triggers(rule_ids)
    _rule_ids = rule_ids.present? ? rule_ids : []
    @suggested_task.rule_triggers = _rule_ids.map{|rule_id| Trigger::RuleTrigger.new(:rule_id => rule_id) }
  end

  def set_up_survey_trigger(survey_id)
    _survey_id = survey_id.present? ? survey_id : nil

    return if @suggested_task.survey_trigger.try(:survey_id) == _survey_id
    @suggested_task.survey_trigger.destroy if @suggested_task.survey_trigger

    if _survey_id
      @suggested_task.survey_trigger = Trigger::SurveyTrigger.create!(:survey_id => _survey_id)
    end
  end
end
