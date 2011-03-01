class ApplicationController < ActionController::Base
  has_mobile_fu
  before_filter :mobile_if_mobile_device

  before_filter :authenticate
  before_filter :load_act_entry_select_values

  include Clearance::Authentication
  protect_from_forgery

  private

  def load_act_entry_select_values
    # TODO: cache this.
    keys = Key.includes(:rules)

    # We don't do "Rule.all" because we want to skip coded rules.

    @act_entry_key_names = keys.map(&:name).sort
    @act_entry_rule_values = keys.inject([]) {|acc, key| acc + key.rules.map(&:value)}.uniq.sort
  end

  def determine_layout
    if request.xhr?
      'ajax'
    else
      'application'
    end
  end

  def force_html_format
    request.format = :html
  end

  def mobile_if_mobile_device
    request.format = :mobile if is_mobile_device?
  end
end
