# frozen_string_literal: true

class ClientAdmin::TilesDigestPreviewsController < ClientAdminBaseController
  layout false

  def email
    @demo  = current_board
    @user  = @demo.users.new(name: "Test User")
    @follow_up_email = params[:follow_up_email] == "true"
    presenter_class = @follow_up_email ? FollowUpDigestPreviewPresenter : TilesDigestPreviewPresenter
    @presenter = presenter_class.new(@user, @demo)

    @tiles = tiles

    render "tiles_digest_mailer/notify_one", layout: false
  end

  def sms
    @user = current_board.users.new(name: "Test User")
    @tile = first_tile_for_digest
    @digest = { tile: @tile }
  end

  private

    def first_tile_for_digest
      tiles.first
    end

    def tiles
      current_board.digest_tiles.segmented_on_population_segments(segment_ids)
    end

    def segment_ids
      segment_id = params[:population_segment_id].to_i

      if segment_id > 0
        [segment_id]
      else
        []
      end
    end
end
