class Admin::RulesController < AdminBaseController
  include Admin::RulesHelper

  before_filter :find_demo, :only => [:index, :new]
  before_filter :find_existing_rules, :only => [:index]
  before_filter :find_rule, :only => [:edit, :update]
  before_filter :extract_primary_and_secondary_values, :only => [:create, :update]

  def index
    @new_rule_path = new_rule(@demo)
  end

  def new
    @rule = Rule.new
    @primary_value = RuleValue.new
    @secondary_values = [RuleValue.new]
    @commit_path = create_rule(@demo)
  end

  def create
    rule = Rule.create_with_rule_values(params[:rule], params[:demo_id], @primary_value, @secondary_values.values)

    if rule.errors.empty?
      flash[:success] = "Rule created."
    else
      flash[:failure] = "Couldn't create rule: #{rule.errors.full_messages}"
    end

    redirect_to rules_index(params[:demo_id])
  end

  def edit
    @primary_value = @rule.primary_value
    @secondary_values = @rule.secondary_values.alphabetical.all
  end

  def update
debugger
    keys = []
    unless params[:rule][:tag_ids].nil?
      params[:rule][:tag_ids].each do |k, v|
        keys << k
      end
    end
    @rule.tag_ids = keys
    params[:rule].delete(:tag_ids)
    if @rule.update_with_rule_values(params[:rule], @primary_value, (@secondary_values.try(:values) || []))
      flash[:success] = 'Rule updated'
    else
      flash[:failure] = "Couldn't update rule: #{@rule.errors.full_messages}"
    end
    redirect_to rules_index(@rule.demo)
  end

  protected

  def find_demo
    @demo = Demo.find(params[:demo_id]) if params[:demo_id]
  end

  def find_rule
    @rule = Rule.find(params[:id])
  end

  def find_existing_rules
    @existing_rules = Rule.where(:demo_id => @demo.try(:id)).includes(:rule_values).sort_by{|rule| rule.primary_value.value}
  end

  def extract_primary_and_secondary_values
    @primary_value = params[:rule].delete(:primary_value)
    if @primary_value.blank?
      flash[:failure] = "You can't blank out the primary value of a rule"
      redirect_to :back
      return false
    end

    @secondary_values = params[:rule].delete(:secondary_values)
  end
end
