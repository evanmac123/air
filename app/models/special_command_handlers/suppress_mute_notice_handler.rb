require 'special_command_handlers/base'

class SpecialCommandHandlers::SuppressMuteNoticeHandler < SpecialCommandHandlers::Base
  def handle_command
    @user.update_attributes(:suppress_mute_notice => true)
    parsing_success_message("OK, we won't remind you about the MUTE command henceforth.")
  end
end
