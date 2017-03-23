class CreateTilesDigests < ActiveRecord::Migration
  def change
    create_table :tiles_digests do |t|
      t.references :demo
      t.integer :sender_id
      t.integer :recipient_count, default: 0
      t.text :custom_headline
      t.text :custom_message
      t.text :subject
      t.text :alt_subject

      t.timestamps
    end
    add_index :tiles_digests, :sender_id
    add_index :tiles_digests, :demo_id
  end
end
