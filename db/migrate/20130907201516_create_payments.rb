class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.text       :raw_stripe_charge
      t.integer    :amount
      t.belongs_to :user
      t.belongs_to :demo
      t.belongs_to :balance

      t.timestamps
    end
  end
end
