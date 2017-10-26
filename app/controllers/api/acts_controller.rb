class Api::ActsController < Api::ApiController
  include AuthorizePublicBoardsConcern
  include AllowGuestUsersConcern

  def index
    @acts = find_requested_acts
  end

  private

    def find_requested_acts
      Act.displayable_to_user(viewing_user: current_user, page: params[:page], per_page: params[:perPage])
    end
end
