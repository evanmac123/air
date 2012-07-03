class Admin::TargetedMessagesController < AdminBaseController
  FIELDS_TO_KEEP = %w(subject plain_text html_text sms_text)

  before_filter :find_demo_by_demo_id
  before_filter :find_segmentation_results

  def show
    FIELDS_TO_KEEP.each do |field_to_keep|
      eval <<-END_EVAL
        @#{field_to_keep} ||= session[:#{field_to_keep}]
        session.delete(:#{field_to_keep})
      END_EVAL
    end

    load_characteristics(@demo)
  end

  def create
    user_ids = @segmentation_results.found_user_ids
    users = User.where(:id => user_ids)

    subject = params[:subject]
    plain_text = params[:plain_text]
    html_text = params[:html_text]
    sms_text = params[:sms_text]
    respect_notification_method = params[:respect_notification_method].present?

    successes = []
    notices = []

    if respect_notification_method
      email_recipients = users.wants_email
      sms_recipients = users.wants_sms
    else
      email_recipients = sms_recipients = users
    end

    if plain_text.present? || html_text.present?
      GenericMailer::BulkSender.delay.bulk_generic_messages(email_recipients.map(&:id), subject, plain_text, html_text)
      successes << "Scheduled email to #{email_recipients.length} users."
    else
      notices << "Email text blank, no emails sent."
    end

    if sms_text.present?
      SMS.delay.bulk_send_messages(sms_recipients.map(&:id), sms_text)
      successes << "Scheduled SMS to #{sms_recipients.length} users."
    else
      notices << "SMS text blank, no SMSes sent."
    end

    flash[:success] ||= ''
    flash[:notice] ||= ''

    flash[:success] = ([flash[:success]] + successes).join(' ')
    flash[:notice] = ([flash[:notice]] + notices).join(' ')

    flash.delete(:success) if flash[:success].blank?
    flash.delete(:notice) if flash[:notice].blank?

    # Cheap hack to set the message form fields correctly when we land back
    # on the targeted messages page, since we may want to re-use them.

    FIELDS_TO_KEEP.each do |field_to_keep|
      session[field_to_keep] = params[field_to_keep]
    end

    redirect_to :back
  end

  protected

  def find_segmentation_results
    @segmentation_results = current_user.segmentation_results
  end
end
