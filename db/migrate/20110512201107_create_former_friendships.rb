class CreateFormerFriendships < ActiveRecord::Migration
  def self.up
    create_table :former_friendships do |t|
      t.belongs_to :user
      t.belongs_to :friend

      t.timestamps
    end

    add_index :former_friendships, :user_id
    add_index :former_friendships, :friend_id
  end

  def self.down
    drop_table :former_friendships
  end
end
