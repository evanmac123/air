class SMS::BulkSendingJob
  def initialize(sms_recipient_ids, sms_text)
    @sms_recipient_ids = sms_recipient_ids
    @sms_text = sms_text
  end

  def perform
    users = User.where(:id => @sms_recipient_ids)
    users.each {|user| SMS.send_message(user, @sms_text)}
  end
end
