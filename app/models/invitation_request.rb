class InvitationRequest 
  include ActiveModel::Validations
  include ActiveModel::Conversion

  attr_accessor :email

  validates_presence_of :email, :message => "You must enter your e-mail address to request an invitation."

  def initialize(values={})
    @email = values[:email]
    @email = @email.strip.downcase if @email
  end

  def persisted?
    false
  end

  def email_domain
    self.email.email_domain
  end

  def self_inviting_domain
    return nil unless self.email
    SelfInvitingDomain.where(:domain => self.email_domain).first
  end

  def create_and_invite_user
    user = User.create!(:email => email, :demo => self_inviting_domain.demo)
    user.invite
    user
  end

  def duplicate_email?
    User.where(:email => self.email).present?
  end
end
