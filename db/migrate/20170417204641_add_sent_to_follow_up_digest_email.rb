class AddSentToFollowUpDigestEmail < ActiveRecord::Migration
  def change
    add_column :follow_up_digest_emails, :sent, :boolean, default: false
  end
end
