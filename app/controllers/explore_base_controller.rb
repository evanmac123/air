class ExploreBaseController < ApplicationController
  include AllowGuestUsersConcern

  layout "explore_layout"

  private

    def find_board_for_guest
      Demo.new
    end
end
