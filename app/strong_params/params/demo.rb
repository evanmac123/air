module Params
  module Demo

    def demo
      params.require(:demo).permit(*demo_attributes)
    end

    #Todo make all fields allowed if site admin
    def demo_attributes
      attrs = [
               :name,
               :seed_points,
               :custom_welcome_message,
               :ends_at,
               :followup_welcome_message,
               :followup_welcome_message_delay,
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
               :login_announcement,
               :total_user_rankings_last_updated_at,
               :average_user_rankings_last_updated_at,
               :mute_notice_threshold,
               :join_type,
               :sponsor,
               :example_tooltip,
               :example_tutorial,
               :ticket_threshold,
               :client_name,
               :custom_reply_email_name,
               :custom_already_claimed_message,
               :use_post_act_summaries,
               :custom_support_reply,
               :internal_domains,
               :show_invite_modal_when_game_closed,
               :tile_digest_email_sent_at,
               :tutorial_type,
               :unclaimed_users_also_get_digest,
               :public_slug,
               :is_public,
               :upload_in_progress,
               :users_last_loaded,
               :turn_off_admin_onboarding,
               :tile_last_posted_at,
               :use_location_in_conversion,
               :persistent_message,
               :logo_file_name,
               :logo_content_type,
               :logo_file_size,
               :logo_updated_at,
               :allow_raw_in_persistent_message,
               :is_parent,
               :everyone_can_make_tile_suggestions,
               :cover_message,
               :cover_image_file_name,
               :cover_image_content_type,
               :cover_image_file_size,
               :cover_image_updated_at]

     if current_user.is_site_admin?
       attrs.concat [:is_paid, :dependent_board_enabled, :dependent_board_id] 
     end
     attrs.concat [ ] if current_user.is_client_admin?
     attrs
    end
  end
end
