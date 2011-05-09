class Admin::RulesController < AdminBaseController
  before_filter :find_demo

  def index
    @existing_rules = @demo.rules.alphabetical
    @new_rules = [Rule.new]
  end

  def edit
    @existing_rules = @demo.rules.alphabetical
    @new_rules = [Rule.find(params[:id])]
    render :action => :index
  end

  def create
    Rule.transaction do
      params[:rule].values.each do |rule_values|
        rule = Rule.where(:value => rule_values['value'].downcase, :demo_id => @demo.id).first

        if rule
          rule.attributes = rule_values
        else
          rule = Rule.new(rule_values.merge(:demo_id => @demo.id))
        end

        rule.save!
      end 
    end

    redirect_to :action => :index
  end
  
  protected

  def find_demo
    @demo = Demo.find(params[:demo_id])
  end
end
