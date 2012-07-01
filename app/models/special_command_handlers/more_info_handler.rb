require 'special_command_handlers/base'

class SpecialCommandHandlers::MoreInfoHandler < SpecialCommandHandlers::Base
  def handle_command
    MoreInfoRequest.create!(
      :phone_number => @user.phone_number,
      :command      => 'moreinfo'
    )

    parsing_success_message("Great, we'll be in touch. Stay healthy!")
  end
end
