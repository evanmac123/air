class LeadContact < ActiveRecord::Base

  belongs_to :user
  belongs_to :organization

  has_one :demo, through: :user

  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :name, presence: true
  validates :phone, presence: true, uniqueness: true
  validates :organization_name, presence: true
  validates :organization_size, presence: true

  before_create :build_lead_contact
  after_create  :notify!

  scope :pending, -> { where(status: "pending").order(:updated_at).reverse_order }
  scope :approved, -> { where(status: "approved").order(:updated_at).reverse_order }
  scope :processed, -> { joins(:demo).where(status: "processed").where(demo: { tile_digest_email_sent_at: nil } ).order(:updated_at).reverse_order }

  after_destroy do
    destroy_board_and_users
  end

  def notify!
    if source == "Inbound: Signup Request"
      LeadContactNotifier.delay_mail(:signup_request, self)
    elsif source == "Inbound: Demo Request"
      LeadContactNotifier.delay_mail(:demo_request, self)
    end
  end

  private

    def destroy_board_and_users
      add_deleted_lead_contacts_to_redis
      # user.destroy if user # FIXME: figure out why user/demo destroys are timing out due to segmentation
    end

    def add_deleted_lead_contacts_to_redis
      attrs = {
        name:name,
        email: email,
        phone: phone,
        org: organization_name
      }

      $redis.sadd("deleted_lead_contacts", attrs.to_json)
    end

    def build_lead_contact
      add_initial_status
      parse_phone_number
      parse_organization_name
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
