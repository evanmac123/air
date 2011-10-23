class Admin::GoalsController < AdminBaseController
  before_filter :find_demo
  before_filter :find_goal, :only => [:edit, :update, :destroy]

  def index
    @goals = @demo.goals.order(:name)
  end

  def new
    @goal = @demo.goals.new
    create_eligible_rule_collection
  end

  def create
    @demo.goals.create(params[:goal])
    redirect_to admin_demo_goals_path(@demo)
  end

  def edit
    create_eligible_rule_collection
  end

  def update
    @goal.attributes = params[:goal]
    @goal.save!
    redirect_to admin_demo_goals_path(@demo)
  end

  def destroy
    @goal.destroy
    redirect_to admin_demo_goals_path(@demo)
  end

  protected

  def find_demo
    @demo = Demo.find(params[:demo_id])
  end

  def find_goal
    @goal = @demo.goals.find(params[:id])
  end

  def create_eligible_rule_collection
    eligible_rules = Rule.eligible_for_goal(@goal).map{|rule| [rule.primary_value.value, rule.id]}.sort_by(&:first)
    @eligible_rule_collection = ActiveSupport::OrderedHash.new
    eligible_rules.each do |eligible_rule_value, eligible_rule_id|
      @eligible_rule_collection[eligible_rule_value] = eligible_rule_id
    end
  end
end
