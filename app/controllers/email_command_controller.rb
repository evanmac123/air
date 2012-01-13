class EmailCommandController< ApplicationController
  include Reply

  skip_before_filter :authenticate
  skip_before_filter :force_ssl
  skip_before_filter :verify_authenticity_token

  HEARTBEAT_CODE = '738a718e819a07289df0fd0cf573e337'

  def create
    # create a EmailCommand object from the raw message
    email_command = EmailCommand.create_from_incoming_email(params)      

    if email_command.email_from.blank?
      # can't respond because we have no return email address
      email_command.status = EmailCommand::Status::FAILED
    elsif email_command.clean_command_string.blank?
      email_command.response = blank_body_response
      email_command.status = EmailCommand::Status::SUCCESS
    elsif email_command.user.nil?
      if email_command.clean_command_string == "join"
        if User.self_inviting_domain(email_command.email_from)
          email_command.status = EmailCommand::Status::INVITATION
          send_invitation(email_command)
          set_success_response! and return # Setting response prevents rendering
        else
          # Not a self inviting domain
          parsed_domain = User.get_domain_from_email(email_command.email_from)
          email_command.response = invalid_domain_response(parsed_domain) 
          email_command.status = EmailCommand::Status::FAILED
          send_response_to_non_user(email_command)
          set_success_response! and return # Setting response prevents rendering
        end
      else
        # send a response to the email saying the email they're sending from isn't registered?
        email_command.status = EmailCommand::Status::FAILED
      end
    elsif email_command.clean_command_string == "join"
      email_command.response = "It looks like you are already registered"
      email_command.status = EmailCommand::Status::FAILED
    elsif email_command.user.phone_number.blank?
      # are we maybe trying to claim an account?
      return if claim_account(email_command) # we sent response already
      # maybe we were, but it didn't work
      email_command.response = unmatched_claim_code_response
    else
      email_command.response = construct_reply(Command.parse(email_command.user, email_command.clean_command_string, :allow_claim_account => false, :channel => :email))
      email_command.status = EmailCommand::Status::SUCCESS
    end

    email_command.save

    # let DJ handle the email response
    EmailCommandMailer.delay.send_response(email_command)

    # a status of 404 would reject the mail
    set_success_response!
    render :text => "OK"
  end

  protected

  def heartbeat_request?
    params['Heartbeat'] == HEARTBEAT_CODE
  end

  def set_success_response!
    self.response_body = 'success'
    self.content_type  = "text/plain"
    self.status = 200
  end

  def claim_account(email_command)
    email_command.response = User.claim_account(email_command.email_from, email_command.clean_command_string, :channel => :email)
    return nil unless email_command.response

    email_command.status = EmailCommand::Status::SUCCESS
    email_command.save
    set_success_response!
    send_claim_response(email_command)

    true
  end


  def send_invitation(email_command)
    email_command.response = "This is not the actual response we sent. Actually, we sent them a nicely formatted Invitation email and a dozen roses :)"
    email_command.status = EmailCommand::Status::INVITATION
    email_command.save
    set_success_response!
    email = email_command.email_from
    user = User.new(:email => email)
    user.demo = Demo.find(User.self_inviting_domain(email).demo_id)
    user.save
    Mailer.delay.invitation(user)
    true
  end
  
  
  def send_claim_response(email_command)
    EmailCommandMailer.delay.send_claim_response(email_command)
  end

  def send_response_to_non_user(email_command)
    EmailCommandMailer.send_response_to_non_user(email_command).deliver
  end

  def unmatched_claim_code_response
    "That user ID doesn't match the one we have in our records. Please try again, or email help@hengage.com for assistance from a human."
  end

  def blank_body_response
    "We got your email, but it looks like the body of it was blank. Please put your command in the first line of the email body."
  end
  
  def invalid_domain_response(domain)
    "The domain '#{domain}' is not valid for this game."
  end
  
  def self.channel_specific_translations
    {:say => "email", :Say => "Email"}
  end
  
  
end
