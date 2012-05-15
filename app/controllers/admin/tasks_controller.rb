class Admin::TasksController < AdminBaseController
  before_filter :find_demo_by_demo_id
  before_filter :find_task, :only => [:edit, :update]

  def index
    @tasks = @demo.tasks.alphabetical.includes(:prerequisites).includes(:rule_triggers)
  end

  def new
    @task = @demo.tasks.new
    @surveys = @demo.surveys
    @existing_tasks = find_existing_tasks(@demo)
    @primary_values = RuleValue.visible_from_demo(@demo).primary.alphabetical
  end

  def create
    @task = @demo.tasks.build(params[:task])
    @task.save!

    set_up_completion_triggers

    flash[:success] = "New task created"
    redirect_to :action => :index
  end

  def edit
    @existing_tasks = find_existing_tasks(@demo) - [@task] # no circular dependencies kthx
    @surveys = @demo.surveys
    @primary_values = RuleValue.visible_from_demo(@demo).primary.alphabetical
    @selected_rule_ids = @task.rule_triggers.map(&:rule_id)
    @require_referrer = @task.rule_triggers.first.try(:referrer_required)
    @selected_survey_id = @task.survey_trigger.try(:survey_id)
    @complete_by_demographic = @task.has_demographic_trigger?
  end

  def update
    @task.attributes = params[:task]
    @task.save!
    set_up_completion_triggers

    flash[:success] = "Task updated"
    redirect_to :action => :index
  end

  protected
  
  def find_task
    @task = Task.find(params[:id])
  end

  def find_existing_tasks(demo)
    @demo.tasks.alphabetical  
  end

  def set_up_completion_triggers
    return unless params[:completion].present?

    set_up_rule_triggers(params[:completion][:rule_ids], params[:completion][:referrer_required])
    set_up_survey_trigger(params[:completion][:survey_id])
    set_up_demographic_trigger(params[:completion][:demographics])
  end

  def set_up_rule_triggers(rule_ids, referrer_required)
    _rule_ids = rule_ids.present? ? rule_ids : []
    referrer_required = referrer_required || false

    @task.rule_triggers = _rule_ids.map{|rule_id| Trigger::RuleTrigger.new(:rule_id => rule_id, :referrer_required => referrer_required) }
  end

  def set_up_survey_trigger(survey_id)
    _survey_id = survey_id.present? ? survey_id : nil

    return if @task.survey_trigger.try(:survey_id) == _survey_id
    @task.survey_trigger.destroy if @task.survey_trigger

    if _survey_id
      @task.survey_trigger = Trigger::SurveyTrigger.create!(:survey_id => _survey_id)
    end
  end

  def set_up_demographic_trigger(use_demographic)
    return if use_demographic.present? == @task.has_demographic_trigger?

    if use_demographic
      Trigger::DemographicTrigger.create!(:task => @task)
    else
      @task.demographic_trigger.destroy
    end
  end
end
