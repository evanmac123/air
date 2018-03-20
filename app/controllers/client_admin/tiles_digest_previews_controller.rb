# frozen_string_literal: true

class ClientAdmin::TilesDigestPreviewsController < ClientAdminBaseController
  layout false

  def email
    @user  = current_user
    @demo  = current_board

    @follow_up_email = params[:follow_up_email] == "true"
    presenter_class = @follow_up_email ? FollowUpDigestPreviewPresenter : TilesDigestPreviewPresenter
    @presenter = presenter_class.new(@user, @demo)

    @tiles = @presenter.tiles

    render "tiles_digest_mailer/notify_one", layout: false
  end

  def sms
    @tile = first_tile_for_digest
    @digest = { tile: @tile }
  end

  private

    def first_tile_for_digest
      current_user.demo.digest_tiles.first
    end
end
