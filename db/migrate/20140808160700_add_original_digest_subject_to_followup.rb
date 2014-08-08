class AddOriginalDigestSubjectToFollowup < ActiveRecord::Migration
  def change
    add_column :follow_up_digest_emails, :original_digest_subject, :string
  end
end
