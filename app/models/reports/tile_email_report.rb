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
      loginsBySubjectLine: logins_by_subject_line,
      totalLoginsFromEmail: total_logins,
      followUpStatus: follow_up_status,
      tiles: tile_attributes
    }
  end
  # logins_by_subject_line is too slow -- Consider loading subject lines and then logins in a subsequent call.

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

    def logins_by_subject_line
      @_logins_by_subject_line = tile_email_login_data.inject({}) do |hsh, data|
        subject = data["key"][0]
        hsh[subject] = data["value"] if subject
        hsh
      end
    end

    def total_logins
      logins_by_subject_line.values.inject(:+)
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

    def from_date
      tile_email.created_at.strftime("%Y-%m-%d")
    end

    def to_date
      Date.today.strftime("%Y-%m-%d")
    end

    def tile_email_login_data
      @_tile_email_login_data ||= $mixpanel_client.request("jql", { script: tile_email_logins_jql })
    end

    def tile_email_logins_jql
      %Q|
      function main() {
        return Events(
        {
          from_date: "#{from_date}",
          to_date: "#{to_date}",
          event_selectors: [
            {
              event: "Email clicked",
              selector: `properties["tiles_digest_id"] == "#{tile_email_id}"`
            }
          ]
        })
        .groupBy(
          [
            "properties.subject_line"
          ],
          mixpanel.reducer.count()
        ).sortDesc('value');
      }|
    end

end
