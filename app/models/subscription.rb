class Subscription < ActiveRecord::Base
  belongs_to :organization
  belongs_to :subscription_plan

  has_many   :invoices
  has_many   :invoice_transactions, through: :invoices

  validates :organization, presence: true
  validates :subscription_plan, presence: true
end
