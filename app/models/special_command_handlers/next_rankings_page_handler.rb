require 'special_command_handlers/base'

class SpecialCommandHandlers::NextRankingsPageHandler < SpecialCommandHandlers::Base
  def handle_command
    @user.short_rankings_page!
  end
end
