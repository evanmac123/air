class InvitationRequest 
  include ActiveModel::Validations
  include ActiveModel::Conversion

  attr_accessor :name, :email

  validates_presence_of :name, :message => "You must enter your name to request an invitation."
  validates_presence_of :email, :message => "You must enter your e-mail address to request an invitation."

  def initialize(values={})
    [:name, :email].each {|key| self.send("#{key}=", values[key])}
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
    user = User.create!(:name => name, :email => email, :demo => self_inviting_domain.demo)
    user.invite
    user
  end

  def duplicate_email?
    User.where(:email => self.email).present?
  end
end
