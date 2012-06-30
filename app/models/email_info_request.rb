class EmailInfoRequest < ActiveRecord::Base
  after_create :notify_vlad

  def notify_vlad
    EmailInfoRequestNotifier.info_requested(name, email, phone, comment).deliver!
  end

  def self.phone_prompt
    "Phone number (optional)"
  end
  
  def self.email_prompt
    "Email address"
  end

  def self.name_prompt
    "Your name"
  end

  def self.comment_prompt
    "Thoughts and comments (optional)"
  end


  handle_asynchronously :notify_vlad
end
