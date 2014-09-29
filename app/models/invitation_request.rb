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

  def preexisting_user
    User.where(:email => self.email).first
  end
end
