# frozen_string_literal: true

module TileEmailTrackingConcern
  def track_tile_email_logins(user:)
    if user && params[:email_type].present? && params[:tiles_digest_id].present?
      TileEmailTrackerJob.perform_later(
        user: user,
        email_type: params[:email_type],
        subject_line: params[:subject_line],
        tile_email_id: params[:tiles_digest_id],
        from_sms: params[:from_sms].present?
      )
    end
  end
end
