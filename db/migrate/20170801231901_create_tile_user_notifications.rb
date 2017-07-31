class CreateTileUserNotifications < ActiveRecord::Migration
  def change
    create_table :tile_user_notifications do |t|
      t.references :tile
      t.references :creator, references: :users
      t.string :subject
      t.text :message
      t.string :answer
      t.integer :scope_cd
      t.datetime :delivered_at
      t.integer :recipient_count
      t.datetime :send_at
      t.integer :delayed_job_id

      t.timestamps
    end
    add_index :tile_user_notifications, :tile_id
  end
end
