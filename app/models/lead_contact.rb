# frozen_string_literal: true

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
  after_create  :notify

  def notify
    LeadContactNotifier.notify_sales(self).deliver_later
  end

  private

    def build_lead_contact
      parse_phone_number
      parse_organization_name
    end

    def parse_phone_number
      self.phone = phone.gsub(/\D/, "")
    end

    def parse_organization_name
      self.organization_name = organization_name.split.map(&:capitalize).join(" ")
    end
end
