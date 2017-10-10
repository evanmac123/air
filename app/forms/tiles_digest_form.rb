class TilesDigestForm
  attr_reader :demo,
              :current_user,
              :follow_up_day,
              :custom_message,
              :custom_subject,
              :alt_custom_subject,
              :custom_headline,
              :unclaimed_users_also_get_digest,
              :include_sms

  def initialize current_user, params = {}
    @current_user = current_user
    @demo = current_user.demo

    if params.present?
      set_attribtues(params)
    end
  end

  def set_attribtues(params)
    @unclaimed_users_also_get_digest = set_unclaimed_users_also_get_digest?(params[:digest_send_to])
    @follow_up_day   = params[:follow_up_day]   if params[:follow_up_day].present?
    @custom_message  = params[:custom_message]  if params[:custom_message].present?
    @custom_subject  = params[:custom_subject]  if params[:custom_subject].present?
    @alt_custom_subject = params[:alt_custom_subject] if params[:alt_custom_subject].present?
    @custom_headline = params[:custom_headline] if params[:custom_headline].present?
    @include_sms = params[:include_sms].present?
  end

  def demo_id
    demo.id
  end

  def set_unclaimed_users_also_get_digest?(digest_send_to)
    if digest_send_to == 'true'
      true
    elsif digest_send_to == 'false'
      false
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

  def submit_schedule_digest_and_followup
    TilesDigestScheduler.new(digest_form: self).schedule!
  end

  def submit_send_test_digest
    TilesDigestTester.new(digest_form: self).deliver_test!
  end
end
