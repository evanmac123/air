class EmailCommand < ActiveRecord::Base
  UNMONITORED_MAILBOX_RESPONSE = "Sorry, you've replied to an unmonitored account. For assistance please contact support@airbo.com.".freeze

  include Reply

  belongs_to :user

  module Status
    SUCCESS = 'success'
    FAILED  = 'failed'
    UNKNOWN_EMAIL  = 'unknown_email'
    USER_VERIFIED  = 'user_verified'
    INVITATION = 'invitation_sent'
    SILENT_SUCCESS = 'silent_success'
  end

  STATUSES = [ Status::SUCCESS, Status::FAILED, Status::UNKNOWN_EMAIL, Status::USER_VERIFIED, Status::INVITATION, Status::SILENT_SUCCESS ]
  validates :status, :inclusion => { :in => STATUSES, :message => "%{value} is not a valid status value" }

  AUTORESPONSE_PHRASES = [
    "auto reply",
    "auto-reply",
    "auto response",
    "auto-response",
    "automatic reply",
    "automatic-reply",
    "automatic response",
    "automatic-response",
    "autoresponse",
    "on vacation",
    "out of office",
    "out-of-office",
    "out of the office"
  ]

  def looks_like_autoresponder?
    AUTORESPONSE_PHRASES.any? {|autoresponse_phrase| normalized_clean_subject.include? autoresponse_phrase}
  end

  def too_soon_for_another_unmonitored_mailbox_reminder?
    user.too_soon_for_another_unmonitored_mailbox_reminder?
  end

  def set_attributes_for_unmonitored_mailbox_response
    transaction do
      self.response = UNMONITORED_MAILBOX_RESPONSE
      self.status = EmailCommand::Status::SUCCESS

      user.last_unmonitored_mailbox_response_at = Time.now
      user.save!

      save!
    end
  end

  def self.create_from_incoming_email(params)
    email_command = EmailCommand.new
    email_command.email_to = params['to']
    email_command.email_from = EmailCommand.clean_email_address(params['from'])
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
    address_only = (stripped_version.nil? ? email : stripped_version[1])
    strip_prvs address_only.gsub(/\s+/, "").downcase
  end

  def self.strip_prvs(email)
    email.gsub(/^prvs=[[:xdigit:]]+=/, "")
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

  def normalized_clean_subject
    clean_subject.downcase.gsub(/\s+/, ' ')
  end
end
