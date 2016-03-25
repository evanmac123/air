class RemoveShareLinkIntroSeen < ActiveRecord::Migration
  def up
    remove_column :users, :share_link_intro_seen
    remove_column :guest_users, :share_link_intro_seen
  end

  def down
    add_column :users, :share_link_intro_seen, :boolean
    add_column :guest_users, :share_link_intro_seen, :boolean
  end
end
