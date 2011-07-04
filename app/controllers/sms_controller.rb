class SmsController < ActionController::Metal
  HEARTBEAT_CODE = '738a718e819a07289df0fd0cf573e337'

  def create
    self.content_type  = "text/plain"

    if heartbeat_request?
      self.response_body = 'ok'
      return
    end

    unless params['AccountSid'] == Twilio::ACCOUNT_SID
      self.response_body = ''
      self.status = 404
      return
    end

    RawSms.create!(:from => params['From'], :body => params['Body'], :twilio_sid => params['SmsSid'])

    self.response_body = Command.parse(params['From'], params['Body'], :allow_claim_account => true)
  end

  protected

  def heartbeat_request?
    params['Heartbeat'] == HEARTBEAT_CODE
  end
end
