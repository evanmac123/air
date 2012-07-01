require 'special_command_handlers/base'

class SpecialCommandHandlers::UseSuggestedItemHandler < SpecialCommandHandlers::Base
  def handle_command
    letter_code = @command_name

    chosen_index = letter_code.ord - 'a'.ord
    suggested_item_indices = @user.last_suggested_items.split('|')
    return nil unless suggested_item_indices.length > chosen_index

    rule_value = RuleValue.find(suggested_item_indices[chosen_index])
    parsing_success_message((@user.act_on_rule(rule_value.rule, rule_value, :suggestion_code => letter_code)).first) # throw away error code in this case
  end
end
