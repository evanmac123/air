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
    elsif email_command.user.nil?
      # send a response to the email saying the email they're sending from isn't registered?
      email_command.status = EmailCommand::Status::FAILED
    elsif email_command.user.phone_number.blank?
      # are we maybe trying to claim an account?
      return if claim_account(email_command) # we sent response already
      # maybe we were, but it didn't work
      email_command.response = unmatched_claim_code_response
    elsif email_command.email_plain.blank?
      email_command.response = blank_body_response
      email_command.status = EmailCommand::Status::SUCCESS
    else
      email_command.response = construct_reply(Command.parse(email_command.user, email_command.clean_command_string, :allow_claim_account => false, :channel => :email))
      email_command.status = EmailCommand::Status::SUCCESS
    end

    email_command.save

    # let DJ handle the email response
    EmailCommandMailer.delay.send_response(email_command)

    # a status of 404 would reject the mail
    set_success_response!
    return
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

  def send_claim_response(email_command)
    EmailCommandMailer.delay.send_claim_response(email_command)
  end

  def unmatched_claim_code_response
    "That user ID doesn't match the one we have in our records. Please try again, or email help@hengage.com for assistance from a human."
  end

  def blank_body_response
    "We got your email, but it looks like the body of it was blank. Please put your command in the first line of the email body."
  end

  def self.channel_specific_translations
    {:say => "email", :Say => "Email"}
  end
end
