# frozen_string_literal: true

class Api::ActsController < Api::ApiController
  include AuthorizePublicBoardsConcern
  include AllowGuestUsersConcern

  def index
    @acts = find_requested_acts
    @current_page = params[:page].to_i
    @next_page = @current_page + 1
    @last_page = @acts.length < params[:perPage].to_i
  end

  private

    def find_requested_acts
      ActFinder.call(viewing_user: current_user, page: params[:page], per_page: params[:perPage])
    end
end
