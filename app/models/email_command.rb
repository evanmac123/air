class EmailCommand < ActiveRecord::Base
  belongs_to :user

  module Status
    SUCCESS = 'success'
    FAILED  = 'failed'
    UNKNOWN_EMAIL  = 'unknown_email'
    USER_VERIFIED  = 'user_verified'
  end
  STATUSES = [ Status::SUCCESS, Status::FAILED, Status::UNKNOWN_EMAIL, Status::USER_VERIFIED ]
  validates :status, :inclusion => { :in => STATUSES, :message => "%{value} is not a valid status value" }
  
  def self.create_from_incoming_email(params)
    
    email_command = EmailCommand.new
    email_command.email_to = params['to']
    email_command.email_from = EmailCommand.clean_email_address(params['from'].gsub(/\s+/, ""))
    email_command.email_subject = params['subject']
    email_command.email_plain = params['plain']
    email_command.clean_command_string = EmailCommand.parse_email_body(email_command.email_plain)
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
  
  def self.parse_email_body(email_body)
    return nil if email_body.nil?
    first_line = nil
    array_of_lines = email_body.to_a
    array_of_lines.each { |line|
      unless line.gsub(/\s+/, "").empty?
        first_line = line.split.join(' ')
        break
      end
    }
    first_line
  end
  
  def self.find_user(from_email)
    User.find_by_email(from_email)
  end
  
end
