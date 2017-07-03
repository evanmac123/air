class InvoiceTransaction < ActiveRecord::Base
  belongs_to :invoice

  validates :invoice, presence: true
  validates :type_cd, presence: true

  as_enum :type, payment: 0, refund: 1
  as_enum :result, successful: 0, failed: 1

  def self.paid
    where(type_cd: payment).where(result_cd: successful)
  end

  def create_invoice_transaction_in_chart_mogul
    if successful? && invoice_is_in_chart_mogul?
      ChartMogulService::Transaction.create_payment(transaction: self, invoice: invoice)
    end
  end

  def successful?
    result == :successful
  end

  def paid_date_or_invoice_due_date
    paid_date || invoice.service_period_start
  end

  def invoice_is_in_chart_mogul?
    invoice.chart_mogul_uuid.present?
  end
end
