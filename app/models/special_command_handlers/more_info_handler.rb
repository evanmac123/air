require 'special_command_handlers/base'

class SpecialCommandHandlers::MoreInfoHandler < SpecialCommandHandlers::Base
  def handle_command
    MoreInfoRequest.create!(
      :user    => @user,
      :command => 'info'
    )

    parsing_success_message("Great, we'll be in touch. Stay healthy!")
  end
end
