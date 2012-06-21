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


  def send_response_to_non_user
    self.response = non_user_response(self.email_from) 
    self.status = EmailCommand::Status::FAILED
    self.save
    EmailCommandMailer.delay.send_response_to_non_user(self)
  end


  def handle_unknown_user(options={})
    self.send_response_to_non_user
  end

  def reinvite_user(options={})
    self.status = Status::INVITATION
    save
    self.user.invite(nil, options)
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
    array_of_lines = email_body.split("\n")
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

  def non_user_response(email)
    "The email '#{email}' is not registered for this game."
  end
end
