class Invoice < ActiveRecord::Base
  belongs_to :subscription
  has_many   :invoice_transactions, dependent: :destroy

  validates :subscription, presence: true
  validates :amount_in_cents, presence: true, numericality: true
  validates :type_cd, presence: true
  validates :service_period_start, presence: true
  validates :service_period_end, presence: true
  validate  :valid_service_dates

  as_enum :type, subscription: 0, one_time: 1

  scope :service_ends_tomorrow, -> { where("DATE(service_period_end) = ?", Date.tomorrow) }

  def self.renew_active_invoices
    Invoice.service_ends_tomorrow.each do |invoice|
      subscription = invoice.subscription

      if subscription && subscription.should_renew_invoice?(invoice: invoice)
        puts "Renewing subscription #{invoice.subscription.id}"
        Invoice.renew_invoice(original_invoice: invoice)
      end
    end
  end

  def self.renew_invoice(original_invoice:)
    new_invoice = original_invoice.dup
    new_invoice.service_period_start = original_invoice.service_period_end.advance(days: 1)
    new_invoice.service_period_end = new_invoice.calculate_service_period_end

    if new_invoice.save
      ChartMogulService::Sync.new(organization: new_invoice.organization).sync
    end
  end

  def calculate_service_period_end
    service_period_start + plan.interval_count.send(plan.interval)
  end

  def plan
    if subscription
      subscription.subscription_plan
    end
  end

  def create_subscription_invoice_in_chart_mogul
    ChartMogulService::Invoice.create_subscription_invoice(invoice: self)
  end

  def organization
    subscription.organization
  end

  def subscription_id
    subscription.id
  end

  def find_or_create_payment
    invoice_transactions.paid.first || invoice_transactions.create(type: InvoiceTransaction.payment, result: InvoiceTransaction.successful)
  end

  def valid_service_dates
    if service_period_start > service_period_end
      errors.add(:service_period_end, "cannot be before Service period start.")
    end
  end
end
