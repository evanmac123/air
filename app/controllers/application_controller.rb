class ApplicationController < ActionController::Base
  # In here temporarily until we have enough for people to look at.
  before_filter :authenticate
  before_filter :load_act_entry_select_values

  include Clearance::Authentication
  protect_from_forgery

  has_mobile_fu

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

  def mobile_if_ajax
    if request.xhr?
      request.format = :mobile
    else
      request.format = :html
    end
  end

  def force_html_format
    request.format = :html
  end
end
