class EmailCommandController < ActionController::Metal
  include Reply
  require 'mail'

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
    # create a EmailCommand object from the raw message
    email_command = EmailCommand.create_from_incoming_email(params)      

    if email_command.nil? || email_command.email_from.nil? || email_command.email_from.blank?
      # can't respond because we have no return email
      email_command.status = EmailCommand::Status::FAILED
      email_command.save
    elsif email_command.user.nil?
      # send a response to the email saying the email they're sending from isn't registered?
      email_command.status = EmailCommand::Status::FAILED
      email_command.save
    else
      self.response_body = construct_reply(Command.parse(email_command.user, email_command.clean_command_string, :allow_claim_account => false))
    end

    # a status of 404 would reject the mail
    render :text => 'success', :status => 200 
    
  end

  protected

  def heartbeat_request?
    params['Heartbeat'] == HEARTBEAT_CODE
  end

  def self.channel_specific_translations
    {:say => "Email"}
  end
end
