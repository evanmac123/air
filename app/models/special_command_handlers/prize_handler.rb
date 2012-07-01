require 'special_command_handlers/base'

class SpecialCommandHandlers::PrizeHandler < SpecialCommandHandlers::Base
  def handle_command
    parsing_success_message(@user.demo.prize_message)
  end
end
