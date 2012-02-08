class EmailCommandController< ApplicationController
  include Reply

  skip_before_filter :authenticate
  skip_before_filter :force_ssl
  skip_before_filter :verify_authenticity_token

  HEARTBEAT_CODE = '738a718e819a07289df0fd0cf573e337'

  def create
    # TODO: We have gradually lost control over this monstrosity. Refactor
    # with fire.

    # create a EmailCommand object from the raw message
    email_command = EmailCommand.create_from_incoming_email(params)      

    if email_command.email_from.blank?
      # can't respond because we have no return email address
      email_command.status = EmailCommand::Status::FAILED
    elsif email_command.clean_command_string.blank?
      email_command.response = blank_body_response
      email_command.status = EmailCommand::Status::SUCCESS
    elsif email_command.user.nil?
      if User.self_inviting_domain(email_command.email_from)
        # Email from non-user's self-inviting domain (regarless of content) gets an invitation
        email_command.status = EmailCommand::Status::INVITATION
        send_invitation(email_command)
        set_success_response! and return # Setting response prevents rendering
      else
        # Not a user, and not from a self inviting domain -> Tell them to use their work email
        parsed_domain = email_command.email_from.email_domain
        email_command.response = invalid_domain_response(parsed_domain) 
        email_command.status = EmailCommand::Status::FAILED
        email_command.save
        send_response_to_non_user(email_command)
        set_success_response! and return # Setting response prevents rendering
      end
    # or are we asking for a re-invitation?
    elsif User.self_inviting_domain(email_command.email_from)
      email_command.status = EmailCommand::Status::INVITATION
      email_command.save
      email_command.user.invite
      set_success_response! and return
    # are we maybe trying to claim an account?
    elsif email_command.user.unclaimed?
      return if claim_account(email_command) # we sent response already
      email_command.response = unmatched_claim_code_response
    elsif email_command.clean_command_string == "join"
      email_command.response = "It looks like you are already registered"
      email_command.status = EmailCommand::Status::FAILED
    else
      email_command.response = construct_reply(Command.parse(email_command.user, email_command.clean_command_string, :allow_claim_account => false, :channel => :email))
      email_command.status = EmailCommand::Status::SUCCESS
    end

    email_command.save

    # let DJ handle the email response
    EmailCommandMailer.delay.send_response(email_command)

    # a status of 404 would reject the mail
    set_success_response!
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
    new_user = User.new_self_inviting_user(email_command.email_from)

    email_command.response = "This is not the actual response we sent. Actually, we sent them a nicely formatted Invitation email and a dozen roses :)"
    email_command.status = EmailCommand::Status::INVITATION
    email_command.save

    new_user.invitation_method = "email"
    new_user.save
    new_user.invite

    true
  end
  
  
  def send_claim_response(email_command)
    EmailCommandMailer.delay.send_claim_response(email_command)
  end

  def send_response_to_non_user(email_command)
    EmailCommandMailer.delay.send_response_to_non_user(email_command)
  end

  def unmatched_claim_code_response
    "That username doesn't match the one we have in our records. Please try again, or email help@hengage.com for assistance from a human."
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
