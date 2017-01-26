class BaseTilesDigestMailer < ActionMailer::Base
  helper :email
  helper 'client_admin/tiles'
  helper ApplicationHelper

  has_delay_mail       # Some kind of monkey-patch workaround (not even sure need)
  include EmailHelper
  include ClientAdmin::TilesHelper

  layout nil

  default reply_to: 'support@airbo.com'

  def self.digest_types_for_mixpanel
    {
      "tile_digest" => "Digest - v. 6/15/14",
      "follow_up_digest" => "Follow-up - v. 6/15/14",
      "explore_digest"  => "Explore - v. 1/1/17",
      "weekly_activity_report"  => "Weekly Report - v. 5/20/15",

      #deprecate after a couple months:
      "digest_new_v" => "Digest - v. 6/15/14",
      "follow_new_v" => "Follow-up - v. 6/15/14",
      "explore_v_1" => "Explore - v. 1/1/17",
      "weekly_activity_v_1"  => "Weekly Report - v. 5/20/15"
    }
  end

  def noon
    Date.today.midnight.advance(hours: 12)
  end

  private
    def tiles_by_position
      Tile.where(id: @tile_ids).ordered_by_position
    end

    def ping_on_digest_email(email_type, user, subject = nil)
      TrackEvent.ping( "Email Sent", {email_type: BaseTilesDigestMailer.digest_types_for_mixpanel[email_type], subject_line: subject}, user )
    end
end
