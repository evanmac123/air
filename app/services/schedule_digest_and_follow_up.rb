class ScheduleDigestAndFollowUp
  attr_reader :demo,
              :unclaimed_users_also_get_digest,
              :custom_headline,
              :custom_message,
              :custom_subject,
              :alt_custom_subject,
              :follow_up_day,
              :current_user

  def initialize params
    @demo = params[:demo]
    @unclaimed_users_also_get_digest = params[:unclaimed_users_also_get_digest]
    @custom_headline = params[:custom_headline]
    @custom_message = params[:custom_message]
    @custom_subject = params[:custom_subject]
    @alt_custom_subject = params[:alt_custom_subject]
    @follow_up_day = params[:follow_up_day]
    @current_user = params[:current_user]
  end

  def schedule!
    if create_and_deliver_digest
      update_demo
      schedule_digest_sent_ping
    end
  end

  private

    def create_and_deliver_digest
      digest = TilesDigest.dispatch({
        demo: demo,
        include_unclaimed_users: unclaimed_users_also_get_digest,
        headline: custom_headline,
        message: custom_message,
        subject: custom_subject,
        alt_subject: alt_custom_subject,
        sender: current_user,
      })

      if digest.persisted?
        digest.deliver(follow_up_days_index)
      end
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

    def follow_up_days_index
      @follow_up_days_index ||= FollowUpDigestEmail.follow_up_days(follow_up_day)
    end
end
