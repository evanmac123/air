module TileBuilderForm
  class Keyword < TileBuilderForm::Base
    validate :no_rule_value_conflicts

    def build_objects
      super
      build_rule
      build_rule_values
    end

    def build_rule
      @rule = @demo.rules.build(alltime_limit: 1)
      set_rule_attributes
    end

    def build_rule_values
      @rule_values = []

      if @parameters.present?
        answers.each do |answer|
          @rule_values << RuleValue.new(value: answer)
        end
      end

      @rule_values = nil unless @rule_values.first.present?
    end

    def update_rule
      set_rule_attributes
    end

    def update_rule_values
      @rule_values = []
      entered_answers.each do |answer|
        existing_value = rule.rule_values.find_by_value(answer)
        if existing_value
          @rule_values << existing_value
        else
          @rule_values << rule.rule_values.build(value: answer)
        end
      end
    end


    def after_save_main_objects_hook
      remove_extraneous_rule_values
      associate_rule_values_with_rule
      set_first_rule_value_as_primary
      create_trigger_if_needed
    end

    def before_validate_on_update_hook
      update_rule
      update_rule_values
    end

    def after_save_on_update_hook
      remove_extraneous_rule_values
    end

    def remove_rule_value_error_on_rule
      rule.errors.delete(:rule_values)
    end

    def set_rule_attributes
      if @parameters.present?
        rule.points = @parameters[:points]

        headline = @parameters[:headline]
        rule.reply = "+#{@parameters[:points]} points! Great job! You completed the \"#{headline}\" tile."
        rule.description = @tile.text_of_completion_act
      end
    end

    def create_trigger_if_needed
      return if Trigger::RuleTrigger.where(rule_id: rule.id, tile_id: tile.id).exists?
      Trigger::RuleTrigger.create(rule: rule, tile: tile)
    end

    def associate_rule_values_with_rule
      rule_values.each {|answer| answer.update_attributes(rule_id: rule.id)}
    end

    def set_first_rule_value_as_primary
      rule_values.first.update_attributes(is_primary: true)
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
