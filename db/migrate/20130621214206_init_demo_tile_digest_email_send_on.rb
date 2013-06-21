class InitDemoTileDigestEmailSendOn < ActiveRecord::Migration
  def up
    Demo.all.each { | d| d.update_attribute :tile_digest_email_send_on, 'Never' }
  end

  def down
    Demo.all.each { | d| d.update_attribute :tile_digest_email_send_on, nil }
  end
end
