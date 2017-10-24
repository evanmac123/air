class RemoveAltSubjectFromFollowUpEmails < ActiveRecord::Migration
  def up
    remove_column :follow_up_digest_emails, :user_ids_to_deliver_to
    remove_column :follow_up_digest_emails, :alt_subject
  end

  def down
    add_column :follow_up_digest_emails, :user_ids_to_deliver_to, :text
    add_column :follow_up_digest_emails, :alt_subject, :string
  end
end
