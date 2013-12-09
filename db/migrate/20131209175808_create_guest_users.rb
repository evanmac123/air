class CreateGuestUsers < ActiveRecord::Migration
  def change
    create_table :guest_users do |t|
      t.integer :points, default: 0
      t.integer :tickets, default: 0
      t.integer :ticket_threshold_base, default: 0
      t.belongs_to :demo
      t.timestamps
    end

    add_index :guest_users, :demo_id

    # Make these associations polymorphic
    add_column :tile_completions, :user_type, :string
    add_column :acts, :user_type, :string
    execute "UPDATE tile_completions SET user_type='User'"
    execute "UPDATE acts SET user_type='User'"
  end
end
