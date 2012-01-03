class AddReferringUserIdToAct < ActiveRecord::Migration
  def self.up
    add_column :acts, :referring_user_id, :integer
  end

  def self.down
    remove_column :acts, :referring_user_id
  end
end
