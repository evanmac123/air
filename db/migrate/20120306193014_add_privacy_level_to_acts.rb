class AddPrivacyLevelToActs < ActiveRecord::Migration
  def self.up
    add_column :acts, :privacy_level, :string
    execute "UPDATE acts SET privacy_level = users.privacy_level FROM users WHERE acts.user_id = users.id"
    add_index :acts, :privacy_level
  end

  def self.down
    remove_column :acts, :privacy_level
  end
end
