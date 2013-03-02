class Admin::TargetedMessagesController < AdminBaseController
  FIELDS_TO_KEEP = %w(subject plain_text html_text sms_text)

  before_filter :find_demo_by_demo_id
  before_filter :find_segmentation_results
  before_filter do
    load_characteristics(@demo)
    @scheduled_pushes = @demo.push_messages.incomplete.in_time_order
  end

  def show
    FIELDS_TO_KEEP.each do |field_to_keep|
      eval <<-END_EVAL
        @#{field_to_keep} ||= session[:#{field_to_keep}]
        session.delete(:#{field_to_keep})
      END_EVAL
    end
  end

  def create
    @subject = params[:subject]
    @plain_text = params[:plain_text]
    @html_text = params[:html_text]
    @sms_text = params[:sms_text]
    @respect_notification_method = params[:respect_notification_method].present?
    @send_at = Chronic.parse(params[:send_at])

    @html_text = '' unless sendable_html?(@html_text)

    user_ids = @segmentation_results.found_user_ids
    email_recipient_ids, sms_recipient_ids = User.push_message_recipients(@respect_notification_method, user_ids)

    PushMessage.schedule(
      subject:    @subject,
      plain_text: @plain_text,
      html_text:  @html_text,
      sms_text:   @sms_text,

      email_recipient_ids: email_recipient_ids,
      sms_recipient_ids:   sms_recipient_ids,

      # Saving these values allows us to fetch the users in this segment right before the job is actually run
      respect_notification_method:  @respect_notification_method,
      segment_query_columns:        @segmentation_results.segment_query_columns,
      segment_query_operators:      @segmentation_results.segment_query_operators,
      segment_query_values:         @segmentation_results.segment_query_values,

      segment_description: @segmentation_results.explanation,
      scheduled_for:       @send_at,
      demo_id:             @demo.id
    )

    set_flashes!(email_recipient_ids, sms_recipient_ids)
    render :action => 'show'
  end

  protected

  def find_segmentation_results
    @segmentation_results = current_user.segmentation_results
  end

  def sendable_html?(html)
    return false unless html.present?
    # Don't send HTML that's all tags, no text, unless one of those tags is an
    # <img> tag (which presumably contains the information we want to convey)

    parsed_html = Nokogiri::HTML(html)
    parsed_html.css('img').present? || parsed_html.text.gsub(/[[:space:]]/, '').present?
  end

  def set_flashes!(email_recipient_ids, sms_recipient_ids)
    successes = []
    notices   = []

    if @plain_text.present? || @html_text.present?
      successes << "Scheduled email to #{email_recipient_ids.length} users."
    else
      notices << "Email text blank, no emails sent."
    end

    if @sms_text.present?
      successes << "Scheduled SMS to #{sms_recipient_ids.length} users."
    else
      notices << "SMS text blank, no SMSes sent."
    end

    flash[:success] ||= ''
    flash[:notice] ||= ''

    flash.now[:success] = ([flash[:success]] + successes).join(' ')
    flash.now[:notice] = ([flash[:notice]] + notices).join(' ')

    flash.delete(:success) if flash[:success].blank?
    flash.delete(:notice) if flash[:notice].blank?

  end
end
