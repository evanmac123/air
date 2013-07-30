module TileBuilderForm
  class Keyword < TileBuilderForm::Base
    validate :no_rule_value_conflicts

    def remove_rule_value_error_on_rule
      rule.errors.delete(:rule_values)
    end

    def no_rule_values_given
      # Due to the normalization we do on answers, if there are any non-blank
      # answers at all, there must be a non-blank answer in the first slot.
      @rule_values.first.value.blank?
    end

    def change_blank_answer_error
      @rule_values.each{|rule_value| rule_value.errors.delete(:value)}
      @rule_values.first.errors[:value] = "must have at least one answer"
    end

    def clean_error_messages
      super
      remove_rule_value_error_on_rule
      change_blank_answer_error if no_rule_values_given
    end

    def conflicting_value(value)
      # The rule value already checks whether it conflicts with another value
      # in the same demo itself.
      conflicts_with_standard_playbook_rule(value) ||
      conflicts_with_special_command(value)
    end

    def conflicts_with_standard_playbook_rule(rule_value)
      return nil unless @demo.use_standard_playbook
      RuleValue.existing_value_within_demo(nil, rule_value.value).present?
    end

    def conflicts_with_special_command(rule_value)
      SpecialCommand.is_reserved_word?(rule_value.value)
    end

    def no_rule_value_conflicts
      rule_values.select{|rule_value| rule_value.value.present?}.each do |rule_value|
        value = rule_value.value

        if conflicting_value(rule_value)
          errors.add :base, "\"#{value}\" is already taken"
        end
      end
    end
  end
end
