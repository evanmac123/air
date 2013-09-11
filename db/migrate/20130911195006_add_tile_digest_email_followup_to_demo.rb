class AddTileDigestEmailFollowupToDemo < ActiveRecord::Migration

  class Demo < ActiveRecord::Base ; end

  def up
    add_column :demos, :tile_digest_email_follow_up, :integer

    Demo.reset_column_information
    Demo.update_all tile_digest_email_follow_up: 0
  end

  def down
    remove_column :demos, :tile_digest_email_follow_up
  end
end
