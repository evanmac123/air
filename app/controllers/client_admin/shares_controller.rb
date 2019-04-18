# frozen_string_literal: true

class ClientAdmin::SharesController < ClientAdminBaseController
  def show
    @demo = current_user.demo
    @user = current_user
    @follow_up_emails = @demo.follow_up_digest_emails.scheduled
    @board_is_public = @demo.is_public
    @digest_tiles = @demo.digest_tiles
    @tiles_to_be_sent = @digest_tiles.count
    @recipient_counts = get_recipient_counts
    @tiles_digest_form = TilesDigestForm.new(demo: current_user.demo, user: current_user, params: digest_params)

    digest_sent_modal

    prepend_view_path "client_admin/users"
  end

  def show_first_active_tile
    @demo = current_user.demo

    @first_active_tile = @demo.tiles.draft.ordered_by_position.limit(1)
    render layout: false
  end

  private
    def get_board_memberships(tile_segmentations)
      if tile_segmentations.all?
        @demo.board_memberships
             .joins(:user)
             .joins('INNER JOIN "user_population_segments" ON "user_population_segments"."user_id" = "users"."id"')
             .joins('INNER JOIN "population_segments" ON "population_segments"."id" = "user_population_segments"."population_segment_id"')
             .joins('INNER JOIN "campaigns" ON "population_segments"."id" = "campaigns"."population_segment_id"')
             .where("campaigns.id = ?", tile_segmentations.uniq)
      else
        @demo.board_memberships.non_site_admin
      end
    end

    def get_recipient_counts
      tile_segmentations = @digest_tiles.pluck(:campaign_id)
      bms = get_board_memberships(tile_segmentations)

      {
        all_user_email_recipient_count: bms.all_for_digest.count,
        activated_user_email_recipient_count: bms.claimed_for_digest.count,
        all_user_sms_recipient_count: bms.all_for_digest_sms.count,
        activated_user_sms_recipient_count: bms.claimed_for_digest_sms.count
      }
    end

    def digest_sent_modal
      @digest_sent_type = session.delete(:digest_sent_type)
    end

    def digest_params
      current_draft = current_board.get_tile_email_draft

      if current_draft.present?
        current_draft
      else
        { custom_subject: @digest_tiles[0].try(:headline) }
      end
    end
end
