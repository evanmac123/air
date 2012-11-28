class Admin::GoalsController < AdminBaseController
  before_filter :find_demo_by_demo_id
  before_filter :find_goal, :only => [:edit, :update, :destroy]

  class AssociatedRuleException < Exception; end

  def index
    @goals = @demo.goals.order(:name)
  end

  def new
    @goal = @demo.goals.new
    create_eligible_rule_collection
  end

  def create
    begin
      Goal.transaction do
        @goal = @demo.goals.create!(params[:goal])
        rule_ids = params[:goal].delete(:rule_ids)
        if rule_ids
          rule_ids = rule_ids.select(&:present?).map(&:to_i)
        end

        set_goal_id_on_each_rule(rule_ids)
      end
      redirect_to admin_demo_goals_path(@demo)
    rescue AssociatedRuleException
      create_eligible_rule_collection
      render :new
    end
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

  def set_goal_id_on_each_rule(rule_ids)
    rule_ids ||= []
    rules = Rule.find(rule_ids)
    throw_exception = false
    rules.each do |rule|
      # assign a dummy goal_id to see if it passes validation with a goal_id
      rule.goal_id = -1
      unless rule.valid?
        #add_failure rule.errors.messages[:reply]
        flash.now[:failure] ||= []
        flash.now[:failure] << rule.errors.messages[:reply].join('. ')
        throw_exception = true
      end
    end
    raise AssociatedRuleException, "Goal has invalid rules" if throw_exception
    @goal.rule_ids = rule_ids
  end

end
