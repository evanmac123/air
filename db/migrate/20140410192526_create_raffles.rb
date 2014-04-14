class CreateRaffles < ActiveRecord::Migration
  def change
    create_table :raffles do |t|
      t.datetime :starts_at
      t.datetime :ends_at
      t.text :prizes
      t.text :other_info
      t.string :status
      t.integer :demo_id

      t.timestamps
    end
  end
end
