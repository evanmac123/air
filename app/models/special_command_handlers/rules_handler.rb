require 'special_command_handlers/base'

class SpecialCommandHandlers::RulesHandler < SpecialCommandHandlers::Base
  def handle_command
    # We have this "help_command_explanation" interpolation because we want to
    # leave it out of email entirely, so we use channel_specific_translations
    # to stick it back into SMS and web replies.

    parsing_success_message("CONNECT [someone's ID] - become connected (ex: \"connection bob12\")\nMYID - see your ID\nRANKING - see connections\n@{help_command_explanation}PRIZES - see what you can win")
  end
end
