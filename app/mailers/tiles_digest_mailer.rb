class TilesDigestMailer < ActionMailer::Base

  helper :email, :skin         # loads 'app/helpers/email_helper.rb' & includes 'EmailHelper' into the View. (Ditto for 'skin')
  helper 'client_admin/tiles'  # ditto for 'app/helpers/client_admin/tiles_helper.rb'

  has_delay_mail       # Some kind of monkey-patch workaround (not even sure need)

  include EmailHelper  # Well, the 'helper' above method might include it into the view, but it don't include it in here
  include ClientAdmin::TilesHelper # and ditto

  layout nil#'mailer'

  default reply_to: 'support@air.bo'

  def noon
    Date.today.midnight.advance(hours: 12)
  end

  def notify_all_follow_up_from_delayed_job
    FollowUpDigestEmail.send_follow_up_digest_email.each { |followup| TilesDigestMailer.delay(run_at: noon).notify_all_follow_up(followup.id) }
  end

  def notify_all(demo, unclaimed_users_also_get_digest, tile_ids, custom_headline, custom_message, subject)
    user_ids = demo.users_for_digest(unclaimed_users_also_get_digest).pluck(:id)

    user_ids.reject! { |user_id| BoardMembership.where(demo_id: demo.id, user_id: user_id, digest_muted: true).first.present? }
    user_ids.each { |user_id| TilesDigestMailer.delay.notify_one(demo.id, user_id, tile_ids, subject, false, custom_headline, custom_message) }
  end

  def notify_all_follow_up(followup_id)
    followup = FollowUpDigestEmail.find followup_id
    subject = if followup.original_digest_subject.present?
                "Don't Miss: #{followup.original_digest_subject}"              
              else
                "Don't Miss Your New Tiles"              
              end
    headline = followup.original_digest_headline

    tile_ids = followup.tile_ids
    user_ids = followup.demo.users_for_digest(followup.unclaimed_users_also_get_digest).where(id: followup.user_ids_to_deliver_to).pluck(:id)

    user_ids.reject! { |user_id| TileCompletion.user_completed_any_tiles?(user_id, tile_ids)}
    user_ids.reject! { |user_id| BoardMembership.where(demo_id: followup.demo_id, user_id: user_id, followup_muted: true).first.present? }
    user_ids.each    { |user_id| TilesDigestMailer.delay.notify_one(followup.demo.id, user_id, tile_ids, subject, true, headline, nil) }

    followup.destroy
  end

  def notify_one(demo_id, user_id, tile_ids, subject, follow_up_email, 
      custom_headline, custom_message, custom_from=nil, is_new_invite = nil)
    @demo = Demo.find demo_id
    @user  = User.find user_id # XTR
    return nil unless @user.email.present? # no wasting our time trying to email people for whom we don't have an address # XTR2

    presenter_class = follow_up_email ? TilesDigestMailerFollowupPresenter : TilesDigestMailDigestPresenter
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
    # We send 'claimed' users to the main activities page; 
    # "unclaimed" users have to accept their invitation first
    mail  to:      @user.email_with_name,
          from:    @presenter.from_email,
          subject: subject
  end

  def notify_one_explore  user_id, tile_ids, subject, email_heading, custom_message, custom_from=nil
    @user  = User.find user_id
    return nil unless @user.email.present? # no wasting our time trying to email people for whom we don't have an address

    @presenter = TilesDigestMailExplorePresenter.new(custom_from, custom_message, email_heading, @user.explore_token)

    @tiles = TileExploreDigestDecorator.decorate_collection Tile.where(id: tile_ids).ordered_for_explore, \
                                                            context: { user: @user }

    ping_on_digest_email(@presenter.email_type, @user)

    mail  to:      @user.email_with_name,
          from:    @presenter.from_email,
          subject: subject,
          template_path: 'tiles_digest_mailer',
          template_name: 'notify_one'
  end

  def notify_all_explore tile_ids, subject, email_heading, custom_message, custom_from=nil
    user_ids = User.where{ (is_client_admin) == true | (is_site_admin == true) }
    user_ids.each{ |user_id| TilesDigestMailer.delay.notify_one_explore(user_id, tile_ids, subject, email_heading, custom_message, custom_from=nil) }
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
