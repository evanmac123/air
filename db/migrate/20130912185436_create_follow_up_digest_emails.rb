class CreateFollowUpDigestEmails < ActiveRecord::Migration
  def change
    create_table :follow_up_digest_emails do |t|
      t.belongs_to :demo
      t.text :tile_ids
      t.date :send_on
      t.boolean :unclaimed_users_also_get_digest

      t.timestamps
    end
    add_index :follow_up_digest_emails, :demo_id
  end
end
