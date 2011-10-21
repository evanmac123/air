class EmailCommandController < ActionController::Metal
  include Reply

  HEARTBEAT_CODE = '738a718e819a07289df0fd0cf573e337'

#  def create
#    self.content_type  = "text/plain"

#    if heartbeat_request?
#      self.response_body = 'ok'
#      return
#    end

#    unless params['AccountSid'] == Twilio::ACCOUNT_SID
#      self.response_body = ''
#      self.status = 404
#      return
#    end

#    RawSms.create!(:from => params['From'], :body => params['Body'], :twilio_sid => params['SmsSid'])

#  end


  def create
    # create a Mail object from the raw message
    email_command = Mail.new(params[:message])

    if !movie_poster.new_record?
      render :text => "Success", :status => 201, :content_type => Mime::TEXT.to_s
    else
      render :text => movie_poster.errors.full_messages.join(', '), :status => 422, :content_type => Mime::TEXT.to_s
    end
    self.response_body = construct_reply(Command.parse(params['From'], params['Body'], :allow_claim_account => true))
  end

  protected

  def heartbeat_request?
    params['Heartbeat'] == HEARTBEAT_CODE
  end

  def self.channel_specific_translations
    {:say => "Email"}
  end
end
