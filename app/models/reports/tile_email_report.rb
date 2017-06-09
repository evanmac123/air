class Reports::TileEmailReport
  attr_reader :tile_email

  FOLLOW_UP_SCHEDULED_STATUS = "scheduled".freeze
  FOLLOW_UP_DELIVERED_STATUS = "delivered".freeze
  NO_FOLLOW_UP_STATUS = "no".freeze

  def initialize(tile_email:)
    @tile_email = tile_email
  end

  def attributes
    {
      type: "Reports::TileEmailReport",
      tileEmailId: tile_email_id,
      reportHeader: report_header,
      sender: sender_name,
      tilesCount: tiles_count,
      recipientCount: recipient_count,
      loginsBySubjectLine: subject_lines_with_login_count,
      totalLoginsFromEmail: total_logins,
      followUpStatus: follow_up_status,
      tiles: tile_attributes
    }
  end

  private

    def report_header
      tile_email.created_at.strftime("%B %e, %Y")
    end

    def sender_name
      tile_email.sender_name
    end

    def recipient_count
      tile_email.recipient_count
    end

    def tile_email_id
      tile_email.id
    end

    def tiles
      tile_email.tiles
    end

    def tiles_count
      tiles.count
    end

    def follow_up_status
      if tile_email.follow_up_digest_email
        follow_up_delivered_status
      else
        NO_FOLLOW_UP_STATUS
      end
    end

    def follow_up_delivered_status
      if tile_email.followup_delivered
        FOLLOW_UP_DELIVERED_STATUS
      else
        FOLLOW_UP_SCHEDULED_STATUS
      end
    end

    def subject_lines_with_login_count
      @_subject_lines_with_login_count ||= get_logins_by_subject_line
    end

    def get_logins_by_subject_line
      if tile_email.logins_by_subject_line.present?
        logins_by_subject_line
      else
        subject_line_hash_without_logins
      end
    end

    def logins_by_subject_line(login_data: {})
      tile_email.logins_by_subject_line.each_slice(2) do |logins, subject|
        login_data[subject] = logins.to_i
      end

      login_data
    end

    def subject_line_hash_without_logins
      subjects = [tile_email.subject, tile_email.alt_subject].compact

      subjects.inject({}) do |hsh, subject|
        hsh[subject] = 0
        hsh
      end
    end

    def total_logins
      subject_lines_with_login_count.values.inject(:+) || 0
    end

    def tile_attributes
      tiles.map do |tile|
        {
          id: tile.id,
          image_url: tile.thumbnail.url,
          headline: tile.headline,
          views: tile.total_views,
          completions: tile.interactions
        }
      end
    end
end
