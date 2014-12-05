class ClientAdmin::TilesDigestNotificationsController < ClientAdminBaseController
  def create
    @demo = current_user.demo

    follow_up_days = FollowUpDigestEmail.follow_up_days(params[:follow_up_day])
    # Need to do this because the param is the string "true" or "false"... and the string "false" is true
    unclaimed_users_also_get_digest = (params[:digest_send_to] == 'true' ? true : false)

    custom_message = params[:digest][:custom_message]
    custom_message = nil unless custom_message.present?

    custom_subject = params[:digest][:custom_subject]
    custom_subject = nil unless custom_subject.present?

    custom_headline = params[:digest][:custom_headline]
    custom_headline = nil unless custom_headline.present?

    cutoff_time = @demo.tile_digest_email_sent_at
    schedule_digest_and_followup! @demo, unclaimed_users_also_get_digest, follow_up_days, cutoff_time, custom_headline, custom_message, custom_subject

    @demo.update_attributes tile_digest_email_sent_at: Time.now, unclaimed_users_also_get_digest: unclaimed_users_also_get_digest

    flash[:success] = "Your Tiles has been successfully sent! New Tiles you post will appear in the email preview."
    flash[:digest_sent_flag] = true

    schedule_digest_sent_ping(unclaimed_users_also_get_digest, follow_up_days, custom_message)
    redirect_to :back
  end

  protected

  def schedule_digest_sent_ping(unclaimed_users_also_get_digest, follow_up_days, custom_message)
    receiver_description = unclaimed_users_also_get_digest ? 'all users' : 'only joined users'
    followup_scheduled = follow_up_days > 0
    optional_message_added = custom_message.present?

    ping 'Digest - Sent', {digest_send_to: receiver_description, followup_scheduled: followup_scheduled, optional_message_added: optional_message_added}, current_user
  end

  def schedule_digest_and_followup!(demo, unclaimed_users_also_get_digest, follow_up_days, cutoff_time, custom_headline, custom_message, custom_subject)
    tile_ids = demo.digest_tiles(cutoff_time).pluck(:id)

    digest_subject = custom_subject || "New Tiles"
    TilesDigestMailer.delay.notify_all demo, unclaimed_users_also_get_digest, tile_ids, custom_headline, custom_message, digest_subject

    if follow_up_days > 0
      FollowUpDigestEmail.create!(demo_id:  demo.id,
                                 tile_ids: tile_ids,
                                 send_on:  Date.today + follow_up_days.days,
                                 unclaimed_users_also_get_digest: unclaimed_users_also_get_digest,
                                 original_digest_subject: custom_subject,
                                 original_digest_headline: custom_headline,
                                 user_ids_to_deliver_to: demo.users_for_digest(unclaimed_users_also_get_digest).pluck(:id)
                                 )
    end
  end
end
