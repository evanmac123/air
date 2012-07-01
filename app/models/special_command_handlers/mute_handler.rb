require 'special_command_handlers/base'

class SpecialCommandHandlers::MuteHandler < SpecialCommandHandlers::Base
  def handle_command
    @user.mute_for_now
    parsing_success_message("OK, you won't get any more texts from us for at least 24 hours.")
  end
end
