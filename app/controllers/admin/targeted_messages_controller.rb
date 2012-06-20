class Admin::TargetedMessagesController < AdminBaseController
  before_filter :find_demo_by_demo_id
  before_filter :find_segmentation_results

  def show
    load_characteristics(@demo)
  end

  def create
    user_ids = @segmentation_results.found_user_ids
    subject = params[:subject]
    plain_text = params[:plain_text]
    html_text = params[:html_text]
    sms_text = params[:sms_text]

    successes = []
    notices = []

    if plain_text.present? || html_text.present?
      GenericMailer::BulkSender.delay.bulk_generic_messages(user_ids, subject, plain_text, html_text)
      successes << "Scheduled messages to #{user_ids.length} users"
    else
      notices << "Email text blank, no emails sent"
    end

    if sms_text.present?
      SMS.delay.bulk_send_messages(user_ids, sms_text)
      successes << "Scheduled SMS to #{user_ids.length} users"
    else
      notices << "SMS text blank, no SMSes sent"
    end

    flash[:success] ||= ''
    flash[:notice] ||= ''

    flash[:success] = ([flash[:success]] + successes).join(' ')
    flash[:notice] = ([flash[:notice]] + notices).join(' ')

    flash.delete(:success) if flash[:success].blank?
    flash.delete(:notice) if flash[:notice].blank?
    redirect_to :back
  end

  protected

  def find_segmentation_results
    @segmentation_results = current_user.segmentation_results
  end
end
