class PotentialUser < ActiveRecord::Base
  belongs_to :demo
  has_many   :peer_invitations, as: :invitee
  validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i}
  validates_uniqueness_of :invitation_code
  before_create :set_invitation_code

  def is_invited_by referrer 
    Mailer.delay_mail(:invitation, self, referrer)
    PeerInvitation.create!(inviter: referrer, invitee: self, demo: demo)
  end

  def email_with_name
    email
  end

  def name
    ""
  end

  def unclaimed?
    true
  end

  def claimed?
    false
  end

  protected

  def set_invitation_code
    possibly_finished = false

    until(possibly_finished && (self.valid? || self.errors[:invitation_code].empty?))
      possibly_finished = true
      self.invitation_code = Digest::SHA1.hexdigest("--#{Time.now.to_f}--#{self.email}--")
    end
  end
end
