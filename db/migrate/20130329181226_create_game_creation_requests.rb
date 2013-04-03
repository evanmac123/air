class CreateGameCreationRequests < ActiveRecord::Migration
  def change
    create_table :game_creation_requests do |t|
      t.string :customer_name,  null: false, default: ''
      t.string :customer_email, null: false, default: ''
      t.string :company_name,   null: false, default: ''
      t.text   :interests,      null: false, default: ''
      t.timestamps
    end
  end
end
