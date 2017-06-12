class CreateInvoices < ActiveRecord::Migration
  def change
    create_table :invoices do |t|
      t.references :subscription
      t.datetime :due_date
      t.integer :type_cd, default: 0
      t.datetime :service_period_start
      t.datetime :service_period_end
      t.integer :amount_in_cents, default: 0
      t.text :description

      t.timestamps
    end
    add_index :invoices, :subscription_id
  end
end
