class AddAltSubjectToFollowUpDigestEmails < ActiveRecord::Migration
  def change
    add_column :follow_up_digest_emails, :alt_subject, :string
  end
end
