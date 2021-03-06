# frozen_string_literal: true

module Params
  module Demo
    def demo
      params.require(:demo).permit(*demo_attributes)
    end

    # Todo make all fields allowed if site admin
    def demo_attributes
      attrs = [
        :organization_id,
        :unlink,
        :name,
        :seed_points,
        :ends_at,
        :credit_game_referrer_threshold,
        :game_referrer_bonus,
        :use_standard_playbook,
        :begins_at,
        :phone_number,
        :prize,
        :help_message,
        :email,
        :unrecognized_user_message,
        :act_too_early_message,
        :act_too_late_message,
        :referred_credit_bonus,
        :survey_answer_activity_message,
        :total_user_rankings_last_updated_at,
        :average_user_rankings_last_updated_at,
        :sponsor,
        :example_tooltip,
        :example_tutorial,
        :client_name,
        :custom_reply_email_name,
        :internal_domains,
        :show_invite_modal_when_game_closed,
        :public_slug,
        :is_public,
        :upload_in_progress,
        :users_last_loaded,
        :tile_last_posted_at,
        :persistent_message,
        :logo_file_name,
        :logo_content_type,
        :logo_file_size,
        :logo_updated_at,
        :logo,
        :everyone_can_make_tile_suggestions,
        :cover_message,
        :cover_image_file_name,
        :cover_image_content_type,
        :cover_image_file_size,
        :cover_image_updated_at
      ]

      if current_user.is_site_admin?
        attrs.concat [
          :customer_status_cd,
          :dependent_board_enabled,
          :dependent_board_id,
          :dependent_board_email_subject,
          :dependent_board_email_body,
          :alt_subject_enabled,
          :allow_embed_video,
          :guest_user_conversion_modal,
          :launch_date,
          :hide_social,
          :email_version,
          custom_color_palette_attributes: [
            :enabled, :enable_reset, :content_background_reset, :tile_progress_background_reset, :tile_progress_all_tiles_text_reset, :tile_progress_completed_tiles_text_reset, :primary_color, :static_text_color
          ]
        ]
      end

      attrs.concat [ ] if current_user.is_client_admin?
      attrs
    end
  end
end
