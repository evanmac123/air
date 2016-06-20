class CreateContracts < ActiveRecord::Migration
  def change
    create_table :contracts do |t|
      t.string :name
      t.references :organization
      t.date :start_date
      t.date :end_date
      t.decimal :mrr
      t.decimal :arr
      t.decimal :amt_booked
      t.date :date_booked
      t.string :estimate_type
      t.string :rank
      t.integer :term
      t.string :plan
      t.integer :max_users
      t.text :notes

      t.timestamps
    end
    add_index :contracts, :organization_id
  end
end
