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

    reply = construct_reply(Command.parse(params['From'], params['Body'], :allow_claim_account => true, :channel => :sms, :receiving_number => params['To'], :style => EmailStyling.new(get_image_url)))

    OutgoingSms.create!(:to => params['From'], :mate => incoming_sms, :body => reply)

    if @user
      @user.bump_mt_texts_sent_today
    end

    self.response_body = reply
  end

  protected

  def heartbeat_request?
    params['Heartbeat'] == HEARTBEAT_CODE
  end

  def channel_specific_translations
    @user = User.find_by_phone_number(params['From'])

    {
      :say => "text", 
      :Say => "Text",
      :help_command_explanation => "HELP - help desk, instructions\n",
      "reply here" => (@user && "Your username is #{@user.sms_slug} (text MYID if you forget). To play, text to this #.")
    }
  end
  
  def get_image_url # Note this is nearly the same as ApplicationController#get_image_url
    # Note that since root_url is not available, we are hard coding this to always feed from production. 
    'http://hengage.com' # everything but the trailing slash
  end
  
end
