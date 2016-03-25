class RemoveVoteupIntroSeenFromGuestUsers < ActiveRecord::Migration
  def up
    remove_column :guest_users, :voteup_intro_seen
  end

  def down
    add_column :guest_users, :voteup_intro_seen, :boolean
  end
end
