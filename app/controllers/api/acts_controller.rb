class Api::ActsController < Api::ApiController
  include AllowGuestUsersConcern
  include AuthorizePublicBoardsConcern
  include ActsHelper

  def index
    # move to json api instead of html
    @acts = find_requested_acts(current_user.demo, params[:per_page] || 5)

    @content = render_to_string(partial: "acts/feed", locals: { opts: { acts: @acts } })

    render json: {
      success:   true,
      content:   @content,
      lastPage:  @acts.last_page?
    }
  end
end
