class Subscription < ActiveRecord::Base
  belongs_to :organization
  belongs_to :subscription_plan

  has_many   :invoices, dependent: :destroy
  has_many   :invoice_transactions, through: :invoices

  validates :organization, presence: true
  validates :subscription_plan, presence: true
  validate :cancelled_at_is_valid?

  def should_renew_invoice?(invoice:)
    if cancelled_at.nil? || (cancelled_at && cancelled_at > invoice.service_period_end)
      latest_invoice = self.invoices.order(:service_period_end).last
      invoice.id == latest_invoice.id
    end
  end

  def cancelled_at_is_valid?
    return if cancelled_at.nil?

    if invoices.empty?
      errors.add(:cancelled_at, "This subscription has no invoices. You should delete it rather than cancel.")
    elsif cancelled_at <= earliest_invoice_or_org_created_at
      errors.add(:cancelled_at, "Subscription cannot be cancelled before its invoices' earliest service period start.")
    end
  end

  private

    def earliest_invoice_or_org_created_at
      invoice = invoices.order(:service_period_start).first
      invoice.try(:service_period_start) || organization.created_at
    end
end
