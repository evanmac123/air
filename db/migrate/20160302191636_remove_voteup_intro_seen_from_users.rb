class RemoveVoteupIntroSeenFromUsers < ActiveRecord::Migration
  def up
    remove_column :users, :voteup_intro_seen
  end

  def down
    add_column :users, :voteup_intro_seen, :boolean
  end
end
