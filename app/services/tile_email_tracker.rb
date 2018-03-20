# frozen_string_literal: true

class TileEmailTracker
  include TrackEvent

  attr_reader :user, :email_type, :subject_line, :tile_email_id, :from_sms

  def initialize(user:, email_type:, subject_line:, tile_email_id:, from_sms:)
    @tile_email_id = tile_email_id
    @subject_line = subject_line
    @user = user
    @email_type = email_type
    @from_sms = from_sms
  end

  def track
    if valid_subject_line && !user.is_site_admin
      tile_email_clicked_ping
      track_tile_email_logins_in_redis
    else
      false
    end
  end

  private

    def tile_email_clicked_ping
      properties = {
        email_type: email_type,
        subject_line: valid_subject_line,
        tiles_digest_id: tile_email_id,
        from_sms: from_sms
      }

      ping("Email clicked", properties, user)
    end

    def track_tile_email_logins_in_redis
      if tile_email.new_unique_login?(user_id: user.id)
        tile_email.increment_unique_logins_by_subject_line(valid_subject_line)
      end

      tile_email.increment_logins_by_subject_line(valid_subject_line)
      tile_email.increment_sms_logins if from_sms
    end

    def valid_subject_line
      subject_lines = tile_email.all_related_subject_lines
      subject_lines.include?(subject_line) ? subject_line : nil
    end

    def tile_email
      TilesDigest.find_by(id: tile_email_id)
    end
end
