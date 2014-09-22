class CreatePotentialUsers < ActiveRecord::Migration
  def change
    create_table :potential_users do |t|
      t.string :email
      t.string :invitation_code
      t.integer :demo_id

      t.timestamps
    end
  end
end
