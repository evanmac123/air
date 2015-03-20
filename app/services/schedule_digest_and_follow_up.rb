class ScheduleDigestAndFollowUp
  attr_reader :demo, 
              :unclaimed_users_also_get_digest,
              :custom_headline,
              :custom_message,
              :custom_subject,
              :follow_up_day,
              :current_user

  def initialize params
    @demo = params[:demo]
    @unclaimed_users_also_get_digest = params[:unclaimed_users_also_get_digest]
    @custom_headline = params[:custom_headline]
    @custom_message = params[:custom_message]
    @custom_subject = params[:custom_subject]
    @follow_up_day = params[:follow_up_day]
    @current_user = params[:current_user]
  end

  def schedule!
    send_digest
    schedule_followup
    update_demo
    schedule_digest_sent_ping
  end

  protected

  def send_digest
    TilesDigestMailer.delay.notify_all  demo, 
                                        unclaimed_users_also_get_digest, 
                                        tile_ids, 
                                        custom_headline, 
                                        custom_message, 
                                        digest_subject
  end

  def schedule_followup
    return if follow_up_days_index == 0

    FollowUpDigestEmail.create!(
      demo_id:  demo.id,
      tile_ids: tile_ids,
      send_on:  Date.today + follow_up_days_index.days,
      unclaimed_users_also_get_digest: unclaimed_users_also_get_digest,
      original_digest_subject: custom_subject,
      original_digest_headline: custom_headline,
      user_ids_to_deliver_to: user_ids_to_deliver_to
    )
  end

  def update_demo
    demo.update_attributes(
      tile_digest_email_sent_at: Time.now, 
      unclaimed_users_also_get_digest: unclaimed_users_also_get_digest
    )
  end

  def schedule_digest_sent_ping
    receiver_description = unclaimed_users_also_get_digest ? 'all users' : 'only joined users'
    followup_scheduled = follow_up_days_index > 0
    optional_message_added = custom_message.present?

    TrackEvent.ping( 
      'Digest - Sent', 
      {
        digest_send_to: receiver_description, 
        followup_scheduled: followup_scheduled, 
        optional_message_added: optional_message_added
      }, 
      current_user
    )
  end

  def cutoff_time
    demo.tile_digest_email_sent_at
  end

  def tile_ids
    @tile_ids ||= demo.digest_tiles(cutoff_time).pluck(:id)
  end

  def digest_subject
    custom_subject || "New Tiles"
  end

  def user_ids_to_deliver_to
    demo.users_for_digest(unclaimed_users_also_get_digest).pluck(:id)
  end

  def follow_up_days_index
    @follow_up_days_index ||= FollowUpDigestEmail.follow_up_days(follow_up_day)
  end
end