class LeadContact < ActiveRecord::Base
  belongs_to :user

  validates :email, presence: true
  validates :name, presence: true
  validates :phone, presence: true

  before_create :parse_phone_number

  def parse_phone_number
    self.phone = phone.gsub(/\D/, '')
  end
end
