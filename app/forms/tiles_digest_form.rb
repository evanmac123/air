class TilesDigestForm
  # extend  ActiveModel::Naming
  # include ActiveModel::Conversion
  # include ActiveModel::Validations

  attr_reader :demo, 
              :current_user,
              :follow_up_day,
              :custom_message,
              :custom_subject,
              :custom_headline,
              :unclaimed_users_also_get_digest

  def initialize current_user, params = {}
    @current_user = current_user
    @demo = current_user.demo
    if params.present?
      # Need to do this because the param is the string "true" or "false"... and the string "false" is true
      @unclaimed_users_also_get_digest =  if params[:digest_send_to] == 'true' 
                                            true 
                                          elsif params[:digest_send_to] == 'false'
                                            false
                                          end
      @follow_up_day   = params[:follow_up_day]   if params[:follow_up_day].present?
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

  def schedule_digest_and_followup!
    schedule_digest_and_followup = ScheduleDigestAndFollowUp.new(
      demo: demo,
      unclaimed_users_also_get_digest: unclaimed_users_also_get_digest,
      custom_headline: custom_headline,
      custom_message: custom_message,
      custom_subject: custom_subject,
      follow_up_day: follow_up_day,
      current_user: current_user
    )
    schedule_digest_and_followup.schedule!
  end

  def send_test_email_to_self
    send_test_digest
  end

  def send_test_follow_up_to_self
    send_test_digest true
  end

  protected

  def send_test_digest follow_up_email = false
    cutoff_time = demo.tile_digest_email_sent_at
    tile_ids = demo.digest_tiles(cutoff_time).pluck(:id)

    TilesDigestMailer.delay.notify_one  demo.id,
                                        current_user.id,
                                        tile_ids,
                                        (custom_subject || "New Tiles"),
                                        follow_up_email,
                                        custom_headline, 
                                        custom_message
  end
end