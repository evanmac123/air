class Admin::ForbiddenRulesController < AdminBaseController
  def index
    @forbidden_rule_values = RuleValue.forbidden.alphabetical

    @new_forbidden_rule = RuleValue.new
  end

  def create
    new_value = RuleValue.new(:value => params[:rule_value][:value])

    if new_value.save
      flash[:success] = "Forbidden rule #{new_value.value} added"
    else
      flash[:failure] = "Must specify a value for the forbidden rule"
    end

    redirect_to :action => :index
  end

  def destroy
    rule_value = RuleValue.find(params[:id])
    rule_value.destroy

    flash[:success] = "Forbidden rule #{rule_value.value} deleted"

    redirect_to :action => :index
  end
end
