class EmailCommand < ActiveRecord::Base
  include Reply

  belongs_to :user

  module Status
    SUCCESS = 'success'
    FAILED  = 'failed'
    UNKNOWN_EMAIL  = 'unknown_email'
    USER_VERIFIED  = 'user_verified'
    INVITATION = 'invitation_sent'
  end

  STATUSES = [ Status::SUCCESS, Status::FAILED, Status::UNKNOWN_EMAIL, Status::USER_VERIFIED, Status::INVITATION ]
  validates :status, :inclusion => { :in => STATUSES, :message => "%{value} is not a valid status value" }

  def send_invitation
    new_user = User.new_self_inviting_user(self.email_from)

    self.response = "This is not the actual response we sent. Actually, we sent them a nicely formatted Invitation email and a dozen roses :)"
    self.status = Status::INVITATION
    save

    new_user.invitation_method = "email"
    new_user.save
    new_user.invite

    true  
  end

  def send_response_to_non_user
    parsed_domain = self.email_from.email_domain
    self.response = invalid_domain_response(parsed_domain) 
    self.status = EmailCommand::Status::FAILED
    self.save
    EmailCommandMailer.delay.send_response_to_non_user(self)
  end

  def invite_new_user_in_self_inviting_domain
    # Email from non-user's self-inviting domain (regarless of content) gets an invitation
    self.status = EmailCommand::Status::INVITATION
    self.send_invitation
  end

  def handle_unknown_user
    if User.self_inviting_domain(self.email_from)
      self.invite_new_user_in_self_inviting_domain
    else
      # Not a user, and not from a self inviting domain -> Tell them to use their work email
      self.send_response_to_non_user
    end
  end

  def reinvite_user
    self.status = Status::INVITATION
    save
    self.user.invite
  end

  def all_blank?
    self.clean_body.blank? && self.clean_subject.blank?
  end

  def join_email?
    [self.clean_body, self.clean_subject].include? "join"  
  end

  def claim_account
    self.response = User.claim_account(self.email_from, self.clean_body, :channel => :email)
    unless self.response
      self.response = User.claim_account(self.email_from, self.clean_subject, :channel => :email)
    end
    
    return nil unless self.response

    self.status = EmailCommand::Status::SUCCESS
    self.save
    EmailCommandMailer.delay.send_claim_response(self)

    true
  end

  def parse_command
    self.response = construct_reply(Command.parse(self.user, self.clean_body, :allow_claim_account => false, :channel => :email))
  end

  def self.create_from_incoming_email(params)
    email_command = EmailCommand.new
    email_command.email_to = params['to']
    email_command.email_from = EmailCommand.clean_email_address(params['from'].gsub(/\s+/, ""))
    email_command.email_subject = params['subject']
    email_command.email_plain = params['plain']
    email_command.clean_subject = EmailCommand.clean_subject_line(email_command.email_subject)
    email_command.clean_body = EmailCommand.parse_email_body(email_command.email_plain)
    email_command.user = EmailCommand.find_user(email_command.email_from)
    if email_command.user.nil? 
      email_command.status = EmailCommand::Status::UNKNOWN_EMAIL
    else
      email_command.status = EmailCommand::Status::USER_VERIFIED
    end
    email_command.save
    email_command
    
  end
  
  def self.clean_email_address(email)
    stripped_version = email.match(/<(.*?)>/)
    (stripped_version.nil? ? email : stripped_version[1])
  end

  def self.clean_subject_line(text)
    return "" if text.blank?
    text.gsub!( /^re:/i, '' )
    text.gsub!( /^fw:|fwd:/i, '' )
    text.strip
  end
    
  def self.parse_email_body(email_body)
    return "" if email_body.blank?
    first_line = nil
    array_of_lines = email_body.to_a
    array_of_lines.each { |line|
      unless line.gsub(/\s+/, "").empty?
        first_line = line.split.join(' ').downcase
        break
      end
    }
    first_line
  end
  
  def self.find_user(from_email)
    User.find_by_email(from_email)
  end
 
  protected
  
  def channel_specific_translations
    {:say => "email", :Say => "Email"}
  end

  def invalid_domain_response(domain)
    "The domain '#{domain}' is not valid for this game."
  end
end
