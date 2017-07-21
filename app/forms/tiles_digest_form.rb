class TilesDigestForm
  include TilesDigestConcern

  attr_reader :demo,
              :current_user,
              :follow_up_day,
              :custom_message,
              :custom_subject,
              :alt_custom_subject,
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
      @alt_custom_subject = params[:alt_custom_subject] if params[:alt_custom_subject].present?
      @custom_headline = params[:custom_headline] if params[:custom_headline].present?
    end
  end

  def digest_send_to_options
    [['All Users', true], ['Activated Users', false]]
  end

  def digest_send_to_selected
    if @unclaimed_users_also_get_digest.nil?
      demo.unclaimed_users_also_get_digest
    else
      @unclaimed_users_also_get_digest
    end
  end

  def follow_up_day_options
    %w(Never) + Date::DAYNAMES
  end

  def default_follow_up_day
    @follow_up_day || FollowUpDigestEmail::DEFAULT_FOLLOW_UP[Date::DAYNAMES[Date.today.wday]]
  end

  def with_follow_up?
    @follow_up_day && @follow_up_day != "Never"
  end

  def schedule_digest_and_followup!
    schedule_digest_and_followup = ScheduleDigestAndFollowUp.new(
      demo: demo,
      current_user: current_user,
      unclaimed_users_also_get_digest: unclaimed_users_also_get_digest,
      custom_headline: custom_headline,
      custom_message: custom_message,
      custom_subject: custom_subject,
      alt_custom_subject: alt_custom_subject,
      follow_up_day: follow_up_day
    )

    schedule_digest_and_followup.schedule!
  end

  def send_test_email_to_self
    digest = OpenStruct.new(test_digest_params)
    subject = sanitize_subject_line(digest.subject)
    alt_subject = sanitize_subject_line(digest.alt_subject)

    [subject, alt_subject].compact.each do |s|
      TilesDigestMailer.delay.notify_one(
        digest,
        current_user.id,
        "[Test] #{s}",
        TilesDigestMailDigestPresenter
      )
    end

    unless follow_up_day == 'Never'
      [subject, alt_subject].compact.each do |s|
        TilesDigestMailer.delay.notify_one(
          digest,
          current_user.id,
          "[Test] Don't Miss: #{s}",
          TilesDigestMailFollowUpPresenter
        )
      end
    end
  end

  private

    def test_digest_params
      cutoff_time = demo.tile_digest_email_sent_at
      tile_ids = demo.digest_tiles(cutoff_time).pluck(:id)

      {
        id: "test",
        cutoff_time: cutoff_time,
        tile_ids_for_email: tile_ids,
        demo: demo,
        subject: custom_subject || TilesDigest::DEFAULT_DIGEST_SUBJECT,
        alt_subject: alt_custom_subject,
        headline: custom_headline,
        message: custom_message,
      }
    end
end
