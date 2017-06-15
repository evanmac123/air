class AddResultToInvoiceTransactions < ActiveRecord::Migration
  def change
    add_column :invoice_transactions, :result_cd, :integer, default: 0
    add_column :invoice_transactions, :paid_date, :datetime
    add_column :invoice_transactions, :chart_mogul_uuid, :string
  end
end
