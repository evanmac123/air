class BaseTilesDigestMailer < ActionMailer::Base
  helper :email
  helper 'client_admin/tiles'
  helper ApplicationHelper

  has_delay_mail       # Some kind of monkey-patch workaround (not even sure need)
  include EmailHelper  
  include ClientAdmin::TilesHelper 

  layout nil

  default reply_to: 'support@airbo.com'

  def noon
    Date.today.midnight.advance(hours: 12)
  end

	protected

	def tiles_by_position 
		Tile.where(id: @tile_ids).ordered_by_position
	end

	def ping_on_digest_email email_type, user
		TrackEvent.ping( "Email Sent", {email_type: ping_message[email_type]}, user )
	end

	def ping_message
		{
			"digest_new_v" => "Digest - v. 6/15/14",
			"follow_new_v" => "Follow-up - v. 6/15/14",
			"explore_v_1"  => "Explore - v. 8/25/14",
			"weekly_activity_v_1"  => "Weekly Report - v. 5/20/15"
		}
	end
end
