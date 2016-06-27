class UserSettingsChangeLog < ActiveRecord::Base
  belongs_to :user

  def save_email email
    self.email = email
    self.email_token = generate_token(email)
    self.save
  end

  def send_confirmation_for_email
    UserSettingsChangeLogMailer.change_email(self.id)
  end

  def generate_token(val)
    Digest::SHA1.hexdigest "--#{Time.now.to_f}--#{val}--#{self.id}--user_settings_change_log"
  end

  def update_user_email
    user = self.user
    user.email = self.email
    user.save
  end
end
