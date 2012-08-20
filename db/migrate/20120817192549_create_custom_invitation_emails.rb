class CreateCustomInvitationEmails < ActiveRecord::Migration
  def change
    create_table :custom_invitation_emails do |t|
      t.text :custom_html_text
      t.text :custom_plain_text
      t.text :custom_subject
      t.text :custom_subject_with_referrer
      t.integer :demo_id

      t.timestamps
    end

    add_index :custom_invitation_emails, :demo_id
  end
end
