class CreateGuestUsers < ActiveRecord::Migration
  def up
    create_table :guest_users do |t|
      t.integer :points, default: 0
      t.integer :tickets, default: 0
      t.integer :ticket_threshold_base, default: 0
      t.belongs_to :demo
      t.timestamps
    end

    add_index :guest_users, :demo_id

    execute "UPDATE tile_completions SET user_type='User' WHERE user_type IS NULL"
    execute "UPDATE acts SET user_type='User' WHERE user_type IS NULL"
  end

  def down
    drop_table :guest_users
  end
end
