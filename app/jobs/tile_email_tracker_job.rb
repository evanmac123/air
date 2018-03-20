# frozen_string_literal: true

class TileEmailTrackerJob < ActiveJob::Base
  queue_as :default

  def perform(user:, email_type:, subject_line:, tile_email_id:, from_sms:)
    if TilesDigest.find_by(id: tile_email_id)
      tile_email_tracker = TileEmailTracker.new(
        user: user,
        email_type: email_type,
        subject_line: URI.decode(subject_line),
        tile_email_id: tile_email_id,
        from_sms: from_sms
      )

      tile_email_tracker.track
    end
  end
end
