class Admin::RulesController < AdminBaseController
  include Admin::RulesHelper

  before_filter :find_rule, :only => [:edit, :update, :destroy]
  before_filter :find_demo_from_rule, :only => [:update, :destroy]
  before_filter :find_demo_from_params, :only => [:index, :new, :create]
  before_filter :find_existing_rules, :only => [:index]
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

    @tag_ids = params[:rule][:tag_ids]
    remove_tag_ids_from_params
    @rule = Rule.create_with_rule_values(params[:rule], params[:demo_id], @primary_value, @secondary_values.values)
    set_tag_ids
    check_conflicts

    if @rule.errors.empty?
      flash[:success] = "Rule created."
      redirect_to rules_index(params[:demo_id]) and return
    else
      flash_now_and_keep_primary_secondary_values 
      render :new
    end

  end

  # move down..
  def flash_now_and_keep_primary_secondary_values
      flash.now[:failure] = "Couldn't create rule: #{@rule.errors.full_messages.join(', ')}"
      @commit_path = create_rule(@demo)
      @primary_value = RuleValue.new(value: @primary_value)
      array = []
      unless @secondary_values.nil? # @secondary_values can be nil when calling #update
        @secondary_values.each_pair do |key, value|
          array << RuleValue.new(value: value)
        end
        @secondary_values = array
      end
  end

  def edit
    demo_id = params[:demo_id]
    if demo_id
      @demo = Demo.find(demo_id)
    else
      @demo = @rule.try(:demo)
    end
    @primary_value = @rule.primary_value
    @secondary_values = @rule.secondary_values.alphabetical.all
  end

  def update
    @tag_ids = params[:rule][:tag_ids]
    remove_tag_ids_from_params
    set_tag_ids

    if @rule.update_with_rule_values(params[:rule], @primary_value, (@secondary_values.try(:values) || []))
      flash[:success] = 'Rule updated'
      check_conflicts   # Note we are checking conflicts AFTER the update, not before, since we only care about the latest state
      redirect_to rules_index(@rule.demo) and return
    else
      flash_now_and_keep_primary_secondary_values
      render :edit
    end
  end

  def destroy
    flash[:success] = "The '#{@rule.primary_value.value}' rule was deleted"
    @rule.destroy

    redirect_to @demo ? admin_demo_rules_path(@demo) : admin_rules_path
  end

  def remove_tag_ids_from_params
    params[:rule].delete(:tag_ids)
  end

  def set_tag_ids
    keys = []
    unless @tag_ids.nil?
      @tag_ids.each do |k, v|
        keys << k
      end
    end
    @rule.tag_ids = keys
  end

  protected

  def find_demo_from_params
    # Some rules have demo_ids. Others  are part of the 'standard playbook' and therefore don't
    # have demo_ids
    @demo = Demo.find(params[:demo_id]) if params[:demo_id]
  end

  def find_demo_from_rule
    @demo = @rule.try(:demo)
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
  
  def check_conflicts
    @rule.conflicts_with_with_sms_slugs.each do |conflict|
      add_failure conflict
    end
  end
end
