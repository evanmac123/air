class Admin::SuggestedTasksController < AdminBaseController
  before_filter :find_demo_by_demo_id
  before_filter :find_suggested_task, :only => [:edit, :update]

  def index
    @suggested_tasks = @demo.suggested_tasks.alphabetical
  end

  def new
    @suggested_task = @demo.suggested_tasks.new
    @existing_tasks = find_existing_tasks(@demo)
  end

  def create
    @suggested_task = @demo.suggested_tasks.build(params[:suggested_task])
    @suggested_task.save!
    flash[:success] = "New suggested task created"
    redirect_to :action => :index
  end

  def edit
    @existing_tasks = find_existing_tasks(@demo) - [@suggested_task] # no circular dependencies kthx
  end

  def update
    @suggested_task.attributes = params[:suggested_task]
    @suggested_task.save!
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
end
