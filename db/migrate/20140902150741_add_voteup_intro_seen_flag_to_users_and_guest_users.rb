class AddVoteupIntroSeenFlagToUsersAndGuestUsers < ActiveRecord::Migration
  def change
    add_column :users, :voteup_intro_seen, :boolean
    add_column :guest_users, :voteup_intro_seen, :boolean
  end
end
