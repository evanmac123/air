# frozen_string_literal: true

class ClientAdmin::TilesDigestPreviewsController < ClientAdminBaseController
  layout false

  def email
    @demo  = current_board
    @user  = @demo.users.new(name: "Test User", characteristics: {})

    @follow_up_email = params[:follow_up_email] == "true"
    presenter_class = @follow_up_email ? FollowUpDigestPreviewPresenter : TilesDigestPreviewPresenter
    @presenter = presenter_class.new(@user, @demo)

    @tiles = @presenter.tiles

    render "tiles_digest_mailer/notify_one", layout: false
  end

  def sms
    @user = current_board.users.new(name: "Test User", characteristics: {})
    @tile = first_tile_for_digest
    @digest = { tile: @tile }
  end

  private

    def first_tile_for_digest
      current_board.digest_tiles.segmented_for_user(@user).first
    end
end
