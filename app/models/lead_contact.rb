class LeadContact < ActiveRecord::Base
  belongs_to :user

  validates :email, presence: true
  validates :name, presence: true
  validates :phone, presence: true

  before_create :build_lead_contact


  private
    def build_lead_contact
      add_initial_status
      parse_phone_number
    end

    def add_initial_status
      self.status = "pending"
    end

    def parse_phone_number
      self.phone = phone.gsub(/\D/, '')
    end
end
