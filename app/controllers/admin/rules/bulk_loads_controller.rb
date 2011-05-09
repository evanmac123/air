require 'csv'

class Admin::Rules::BulkLoadsController < AdminBaseController
  before_filter :find_demo

  def create
    # Apparently Vlad's machine generates "CSV" files with just \r at the end
    # of a line. "CSV" in quotes because that violates the RFC. But, y'know, 
    # Postel's law.
    raw_new_rule_text = params[:bulk_rules_file].read.strip
    new_rule_text = raw_new_rule_text.gsub(/\r(?!\n)/, "\r\n")

    new_rule_data = CSV.parse(new_rule_text)
    @new_rules = []
    @rule_warnings = {}

    new_rule_data.each_with_index do |new_rule_datum, i|
      value, points, reply, description, alltime_limit, referral_points, suggestible = new_rule_datum

      next if value.blank?
      value.strip!
      # Also can't count on the user not to include the header.
      next if i == 0 and value.downcase =~ /^value/

      suggestible = (suggestible.try(:downcase) == 'false' ? false : true)

      new_rule = Rule.new(:value => value, :points => points, :reply => reply, :description => description, :alltime_limit => alltime_limit, :referral_points => referral_points, :suggestible => suggestible)
      @new_rules << new_rule

      if Rule.where(:value => value.downcase, :demo_id => @demo.id).first
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
