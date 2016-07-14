class UserSettingsChangeLog < ActiveRecord::Base
  belongs_to :user
  validates_with EmailFormatValidator, allow_blank: true
  validates_presence_of :email, :if => :saving_email, :message => "can't be blank"
  validate :unique_user_email

  attr_accessor :saving_email

  def save_email email
    self.saving_email = true
    self.email = email
    self.email_token = generate_token(email)
    self.save
  end

  def send_confirmation_for_email
    UserSettingsChangeLogMailer.delay.change_email(self.id)
  end

  def generate_token(val)
    Digest::SHA1.hexdigest "--#{Time.now.to_f}--#{val}--#{self.id}--user_settings_change_log"
  end

  def update_user_email
    user = self.user
    user.email = self.email
    user.save
  end

  protected
    def unique_user_email
      return if self.email.blank?

      if User.where(email: self.email).first
        self.errors.add :email, "already exists"
      end
    end
end
