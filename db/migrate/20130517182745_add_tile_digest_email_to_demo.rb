class AddTileDigestEmailToDemo < ActiveRecord::Migration
  def change
    add_column :demos, :tile_digest_email_sent_at, :datetime
    add_column :demos, :tile_digest_email_send_on, :string
  end
end
