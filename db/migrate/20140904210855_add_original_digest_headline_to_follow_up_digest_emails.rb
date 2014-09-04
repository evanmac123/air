class AddOriginalDigestHeadlineToFollowUpDigestEmails < ActiveRecord::Migration
  def change
    add_column :follow_up_digest_emails, :original_digest_headline, :string
  end
end
