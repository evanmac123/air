class CreateBillingInformations < ActiveRecord::Migration
  def change
    create_table :billing_informations do |t|
      t.string :expiration_month, null: false, default: ''
      t.string :expiration_year, null: false, default: ''
      t.string :last_4, null: false, default: ''
      t.string :customer_token, null: false, default: ''
      t.string :card_token, null: false, default: ''

      t.belongs_to :user
      t.timestamps
    end

    add_index :billing_informations, :user_id
  end
end
