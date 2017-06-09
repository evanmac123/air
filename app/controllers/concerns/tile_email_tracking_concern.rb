module TileEmailTrackingConcern
  def track_tile_email_logins(user:)
    if user && params[:email_type].present? && params[:tiles_digest_id].present?
      TileEmailTracker.delay.dispatch(
        user: user,
        email_type: params[:email_type],
        subject_line: params[:subject_line],
        tile_email_id: params[:tiles_digest_id]
      )
    end
  end
end
