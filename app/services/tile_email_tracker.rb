class TileEmailTracker
  include TrackEvent

  attr_reader :user, :email_type, :subject_line, :tile_email_id

  def self.dispatch(user:, email_type:, subject_line:, tile_email_id:, from_sms:)
    if TilesDigest.where(id: tile_email_id).exists?
      tile_email_tracker = TileEmailTracker.new(
        user: user,
        email_type: email_type,
        subject_line: subject_line,
        tile_email_id: tile_email_id,
        from_sms: from_sms
      )

      tile_email_tracker.track
    end
  end

  def initialize(user:, email_type:, subject_line:, tile_email_id:, from_sms:)
    @tile_email_id = tile_email_id
    @subject_line = subject_line
    @user = user
    @email_type = email_type
    @from_sms = from_sms
  end

  # Sometimes a user's browser corrupts the subject line param causing an extra subject line to show in tile email analytics. If a subject line comes through that does not match an existing subject line, we will not count the login.
  def track
    if valid_subject_line && !user.is_site_admin
      tile_email_clicked_ping
      track_tile_email_logins_in_redis
    else
      return false
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

    def validate_subject_line
      subject_lines = tile_email.all_related_subject_lines
      subject_lines.include?(subject_line) ? subject_line : nil
    end

    def valid_subject_line
      @_valid_subject_line = validate_subject_line
    end

    def tile_email
      @_tile_email = TilesDigest.where(id: tile_email_id).first
    end

    def follow_up_email
      @_follow_up_email =  tile_email.follow_up_digest_email
    end
end
