class AddTilesDigestToFollowupDigest < ActiveRecord::Migration
  def up
    add_column :follow_up_digest_emails, :tiles_digest_id, :integer
    add_index :follow_up_digest_emails, :tiles_digest_id
    add_column :follow_up_digest_emails, :subject, :text

    remove_column :follow_up_digest_emails, :demo_id
    remove_column :follow_up_digest_emails, :tile_ids
    remove_column :follow_up_digest_emails, :unclaimed_users_also_get_digest
    remove_column :follow_up_digest_emails, :original_digest_subject
    remove_column :follow_up_digest_emails, :original_digest_headline
  end

  def down
    remove_column :follow_up_digest_emails, :tiles_digest_id
    remove_index :follow_up_digest_emails, :tiles_digest_id

    add_column :follow_up_digest_emails, :demo_id, :integer
    add_column :follow_up_digest_emails, :tile_ids, :text
    add_column :follow_up_digest_emails, :unclaimed_users_also_get_digest, :boolean
    add_column :follow_up_digest_emails, :original_digest_subject, :text
    add_column :follow_up_digest_emails, :original_digest_headline, :text
  end
end
