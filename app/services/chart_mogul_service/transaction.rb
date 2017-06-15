class ChartMogulService::Transaction
  def self.create_payment(transaction:, invoice:)
    cm_transaction = ChartMogul::Transactions::Payment.create!(
      invoice_uuid: invoice.chart_mogul_uuid,
      external_id: transaction.id,
      date: transaction.paid_date_or_invoice_due_date,
      result: 'successful'
    )

    if cm_transaction
      transaction.update_attributes(chart_mogul_uuid: cm_transaction.uuid)
    end
  end
end
