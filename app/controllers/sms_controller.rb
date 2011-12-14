class SmsController < ActionController::Metal
  include Reply

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

    incoming_sms = IncomingSms.create!(:from => params['From'], :body => params['Body'], :twilio_sid => params['SmsSid'])

    reply = construct_reply(Command.parse(params['From'], params['Body'], :allow_claim_account => true, :channel => :sms, :receiving_number => params['To']))

    OutgoingSms.create!(:to => params['From'], :in_response_to => incoming_sms, :body => reply)

    self.response_body = reply
  end

  protected

  def heartbeat_request?
    params['Heartbeat'] == HEARTBEAT_CODE
  end

  def self.channel_specific_translations
    {
      :say => "text", 
      :Say => "Text",
      :help_command_explanation => "HELP - help desk, instructions\n"
    }
  end
end
