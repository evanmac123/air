class AddShareLinkIntroSeenFlagToUsersAndGuestUsers < ActiveRecord::Migration
  def change
    add_column :users, :share_link_intro_seen, :boolean
    add_column :guest_users, :share_link_intro_seen, :boolean
  end
end
