class RemoveDigestEmailSendOnFromDemo < ActiveRecord::Migration
  def up
    remove_column :demos, :tile_digest_email_send_on
  end

  def down
    add_column :demos, :tile_digest_email_send_on, :string, default: 'Never'
  end
end
