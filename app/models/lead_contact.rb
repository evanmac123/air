class LeadContact < ActiveRecord::Base

  belongs_to :user

  validates :email, presence: true
  validates :name, presence: true
  validates :phone, presence: true
  validates :organization_name, presence: true
  validates :organization_size, presence: true

  before_create :build_lead_contact

  scope :pending, ->{where(status: "pending")}

  private
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
