class CreateInvoiceTransactions < ActiveRecord::Migration
  def change
    create_table :invoice_transactions do |t|
      t.references :invoice
      t.integer :type_cd, default: 0

      t.timestamps
    end
    add_index :invoice_transactions, :invoice_id
  end
end
