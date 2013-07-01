class ResetDemoTileDigestEmailSentAt < ActiveRecord::Migration
  def up
    Demo.all.each { | d| d.update_attribute :tile_digest_email_sent_at, nil }
  end

  def down
    Demo.all.each { | d| d.update_attribute :tile_digest_email_sent_at, Time.now }
  end
end
