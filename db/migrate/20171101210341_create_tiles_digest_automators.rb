class CreateTilesDigestAutomators < ActiveRecord::Migration
  def change
    create_table :tiles_digest_automators do |t|
      t.references :demo
      t.datetime :deliver_date
      t.integer :day, default: 1
      t.string :time, default: 9
      t.integer :frequency_cd, default: 1

      t.timestamps
    end
    add_index :tiles_digest_automators, :demo_id
  end
end
