module Params
  module User

    def user
      params.require(:user).permit(*user_attributes)
    end

    #Todo make all fields allowed if site admin
    def user_attributes
     attrs = [:name, :email, :invited, :invitation_code,
     :phone_number, :points,  :remember_token, :slug,
     :claim_code, :confirmation_token, :won_at, :sms_slug, :last_suggested_items,
     :avatar_file_name, :avatar_content_type, :avatar_file_size, :avatar_updated_at,
     :ranking_query_offset, :accepted_invitation_at, :game_referrer_id,
     :notification_method, :location_id, :new_phone_number, :new_phone_validation,
     :date_of_birth, :gender, :privacy_level, :last_muted_at, :characteristics,
     :overflow_email, :tickets, :zip_code, :employee_id,
     :spouse_id, :last_acted_at, :ticket_threshold_base, :terms_and_conditions,
     :get_started_lightbox_displayed, :send_weekly_activity_report
    ]

     attrs.concat [:is_site_admin, :is_client_admin, :demo_id, :role] if current_user.is_site_admin?
     attrs.concat [ :is_client_admin, :demo_id, :role] if current_user.is_client_admin?
     attrs
    end
  end
end
