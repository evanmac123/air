class Admin::RulesController < AdminBaseController
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
    if Rule.create_with_rule_values(params[:rule], params[:demo_id], @primary_value, @secondary_values.values)
      flash[:succes] = "Rule created."
    else
      flash[:failure] = "Couldn't create rule: #{@rule.errors.full_messages}"
    end

    redirect_to rules_index(params[:demo_id])
  end

  def edit
    @primary_value = @rule.primary_value
    @secondary_values = @rule.secondary_values.alphabetical.all
  end

  def update
    if @rule.update_with_rule_values(params[:rule], @primary_value, @secondary_values.values)
      flash[:success] = 'Rule updated'
    else
      flash[:failure] = "Couldn't update rule: #{@rule.errors.full_messages}"
    end
    redirect_to rules_index(@rule.demo)
  end

  #def create
    #Rule.transaction do
      #params[:rule].values.each do |rule_params|
        #raw_rule_value_values = rule_params.delete('values')
        #rule_value_values = raw_rule_value_values.split(/,/).map(&:strip).map(&:downcase)
        #rule_values = @demo.rule_values.with_value_in(rule_value_values)

        #rule_ids = rule_values.map(&:rule_id).flatten.uniq

        #if rule_ids.length > 1
          #flash[:failure] ||= ''
          #flash[:failure] += "Ambiguous rule values #{raw_rule_value_values} refer to multiple rules, skipped."
          #next
        #end

        #rule_id = rule_ids.first
        #rule = rule_id ?
          #Rule.where(:id => rule_id).first :
          #nil

        #if rule
          #rule.attributes = rule_params
        #else
          #rule = Rule.new(rule_params)
        #end

        #rule.save!

        #rule_value_values.each do |rule_value_value|
          #next if @demo.rule_values.where(:value => rule_value_value).first
          #@demo.rule_values.create!(:value => rule_value_value, :rule => rule)
        #end
      #end 
    #end

    #redirect_to :action => :index
  #end
  
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

  # Convenience methods that allows us to choose the proper path while
  # glossing over if @demo is nil or not.
  def rules_index(demo)
    demo ? admin_demo_rules_path(demo) : admin_rules_path
  end

  def new_rule(demo)
    demo ? new_admin_demo_rule_path(demo) : new_admin_rule_path
  end

  def create_rule(demo)
    demo ? admin_demo_rules_path(demo) : admin_rules_path
  end
end
