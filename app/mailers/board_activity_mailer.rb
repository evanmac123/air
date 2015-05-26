class BoardActivityMailer < ActionMailer::Base

  helper :email
  helper 'client_admin/tiles'
  helper ApplicationHelper

  has_delay_mail       # Some kind of monkey-patch workaround (not even sure need)

  include EmailHelper  # Well, the 'helper' above method might include it into the view, but it don't include it in here
  include ClientAdmin::TilesHelper # and ditto

  layout nil#'mailer'

  default reply_to: 'support@airbo.com'

  def notify_one(demo_id, user_id, tile_ids, subject, follow_up_email, 
      custom_headline, custom_message, custom_from=nil, is_new_invite = nil)
    @demo = Demo.find demo_id
    @user  = User.find user_id # XTR
    return nil unless @user.email.present? # no wasting our time trying to email people for whom we don't have an address # XTR2

    presenter_class = follow_up_email ? TilesDigestMailFollowupPresenter : TilesDigestMailDigestPresenter
    @presenter = presenter_class.new(@user, @demo, custom_from, custom_headline, custom_message, is_new_invite)

    email_type = @presenter.email_type
    ping_on_digest_email email_type, @user

    @tiles = TileBoardDigestDecorator.decorate_collection Tile.where(id: tile_ids).ordered_by_position, \
                                                          context: {
                                                            demo: @demo,
                                                            user: @user,
                                                            follow_up_email: @follow_up_email,
                                                            email_type: email_type,
                                                          }
    mail  to:      @user.email_with_name,
          from:    @presenter.from_email,
          subject: subject
  end


  def ping_on_digest_email email_type, user
    TrackEvent.ping( "Email Sent", {email_type: ping_message[email_type]}, user )
  end

  def ping_message
    {
      "digest_new_v" => "Digest - v. 6/15/14",
      "follow_new_v" => "Follow-up - v. 6/15/14",
      "explore_v_1"  => "Explore - v. 8/25/14"
    }
  end
end
