class LeadContact < ActiveRecord::Base

  belongs_to :user
  belongs_to :organization

  has_one :demo, through: :user

  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :name, presence: true
  validates :phone, presence: true
  validates :organization_name, presence: true
  validates :organization_size, presence: true

  before_create :build_lead_contact
  after_create  :notify!

  scope :pending, -> { where(status: "pending").order(:updated_at).reverse_order }
  scope :approved, -> { where(status: "approved").order(:updated_at).reverse_order }
  scope :processed, -> { joins(:demo).where(status: "processed").where(demo: { tile_digest_email_sent_at: nil } ).order(:updated_at).reverse_order }


  def notify!
    if source == "Inbound: Signup Request"
      notify_inbound_signup_request
    end
  end

  private
    def build_lead_contact
      add_initial_status
      parse_phone_number
      parse_organization_name
    end

    def notify_inbound_signup_request
      LeadContactNotifier.delay_mail(:signup_request, self)
    end

    def add_initial_status
      self.status = "pending"
    end

    def parse_phone_number
      self.phone = phone.gsub(/\D/, '')
    end

    def parse_organization_name
      self.organization_name = organization_name.split.map(&:capitalize).join(" ")
    end
end
