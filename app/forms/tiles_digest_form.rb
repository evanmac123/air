class TilesDigestForm
  # extend  ActiveModel::Naming
  # include ActiveModel::Conversion
  # include ActiveModel::Validations

  attr_reader :demo, :current_user

  def initialize current_user, params = {}
    @current_user = current_user
    @demo = current_user.demo
    if params.present?
      @follow_up_days_index = FollowUpDigestEmail.follow_up_days(params[:follow_up_day])
      # Need to do this because the param is the string "true" or "false"... and the string "false" is true
      @unclaimed_users_also_get_digest =  if params[:digest_send_to] == 'true' 
                                            true 
                                          elsif params[:digest_send_to] == 'false'
                                            false
                                          end
      @custom_message  = params[:custom_message]  if params[:custom_message].present?
      @custom_subject  = params[:custom_subject]  if params[:custom_subject].present?
      @custom_headline = params[:custom_headline] if params[:custom_headline].present?
    end
  end

  def digest_send_to_options
    [['All Users', true], ['Activated Users', false]]
  end

  def digest_send_to_selected
    demo.unclaimed_users_also_get_digest
  end

  def follow_up_day_options
    %w(Never) + Date::DAYNAMES
  end

  def default_follow_up_day
    FollowUpDigestEmail::DEFAULT_FOLLOW_UP[Date::DAYNAMES[Date.today.wday]]
  end

  def custom_subject
    @custom_subject || ''
  end

  def custom_headline
    @custom_headline || ''
  end

  def custom_message
    @custom_message || ''
  end

  def schedule_digest_and_followup!
    send_digest
    schedule_followup
    update_demo
    schedule_digest_sent_ping
  end

  protected

  def send_digest
    TilesDigestMailer.delay.notify_all  demo, 
                                        @unclaimed_users_also_get_digest, 
                                        tile_ids, 
                                        @custom_headline, 
                                        @custom_message, 
                                        digest_subject
  end

  def schedule_followup
    return if @follow_up_days_index == 0

    FollowUpDigestEmail.create!(
      demo_id:  demo.id,
      tile_ids: tile_ids,
      send_on:  Date.today + @follow_up_days_index.days,
      unclaimed_users_also_get_digest: @unclaimed_users_also_get_digest,
      original_digest_subject: @custom_subject,
      original_digest_headline: @custom_headline,
      user_ids_to_deliver_to: user_ids_to_deliver_to
    )
  end

  def update_demo
    demo.update_attributes(
      tile_digest_email_sent_at: Time.now, 
      unclaimed_users_also_get_digest: @unclaimed_users_also_get_digest
    )
  end

  def schedule_digest_sent_ping
    receiver_description = @unclaimed_users_also_get_digest ? 'all users' : 'only joined users'
    followup_scheduled = @follow_up_days_index > 0
    optional_message_added = @custom_message.present?

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
    @custom_subject || "New Tiles"
  end

  def user_ids_to_deliver_to
    demo.users_for_digest(@unclaimed_users_also_get_digest).pluck(:id)
  end
end