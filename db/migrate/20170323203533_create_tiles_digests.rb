class CreateTilesDigests < ActiveRecord::Migration
  def change
    create_table :tiles_digests do |t|
      t.references :demo
      t.integer :sender_id
      t.datetime :cutoff_time
      t.boolean :only_joined_users
      t.integer :recipient_count, default: 0
      t.text :headline
      t.text :message
      t.text :subject
      t.text :alt_subject
      t.text :tile_ids

      t.timestamps
    end
    add_index :tiles_digests, :sender_id
    add_index :tiles_digests, :demo_id
  end
end
