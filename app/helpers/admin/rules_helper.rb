module Admin::RulesHelper
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
