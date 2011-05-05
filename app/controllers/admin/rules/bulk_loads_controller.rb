require 'csv'

class Admin::Rules::BulkLoadsController < AdminBaseController
  before_filter :find_demo

  def create
    new_rule_data = CSV.parse(params[:bulk_rules_file].read)
    @new_rules = []
    @rule_warnings = {}

    new_rule_data.each do |new_rule_datum|
      value, points, reply, description, alltime_limit, referral_points, suggestible = new_rule_datum
      suggestible = (suggestible.downcase == 'false' ? false : true)

      new_rule = Rule.new(:value => value, :points => points, :reply => reply, :description => description, :alltime_limit => alltime_limit, :referral_points => referral_points, :suggestible => suggestible)
      @new_rules << new_rule

      if Rule.find_by_value(value)
        @rule_warnings[new_rule] = 'A rule with this value already exists. If you add this rule, the existing rule will be overwritten. Which might be what you want.'
      end
    end

    @existing_rules = @demo.rules.alphabetical
    render :action => 'admin/rules/index'
  end

  protected

  def find_demo
    @demo = Demo.find(params[:demo_id])
  end
end
