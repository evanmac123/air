class AdminBaseController < ApplicationController
  before_filter :authenticate

  protected

  def authenticate
    return true if Rails.env.test?

    authenticate_or_request_with_http_basic do |username, password|
      username == "demo" && password == "salud"
    end
  end

  def group_rules_and_values
    rule_values = @demo.rule_values
    grouped_rule_values = rule_values.group_by(&:rule)
    @rules_by_value_string = {}
    grouped_rule_values.each do |rule, rule_values|
      value_string = rule_values.map(&:value).sort.join(',')
      @rules_by_value_string[value_string] = rule
    end

    @value_strings_by_rule = @rules_by_value_string.invert
    @value_strings = @rules_by_value_string.keys.sort
  end
end
