require 'special_command_handlers/base'

class SpecialCommandHandlers::FirstRankingsPageHandler < SpecialCommandHandlers::Base
  def handle_command
    @user.short_rankings_page!(:use_offset => false, :reset_offset => true)
  end
end
