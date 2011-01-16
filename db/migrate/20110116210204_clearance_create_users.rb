class ClearanceCreateUsers < ActiveRecord::Migration
  def self.up
    remove_index :players, :demo_id

    rename_table :players, :users

    change_table(:users) do |t|
      t.string :encrypted_password, :limit => 128
      t.string :salt,               :limit => 128
      t.string :remember_token,     :limit => 128
    end

    add_index :users, :demo_id
    add_index :users, :email
    add_index :users, :remember_token

    rename_column :acts, :player_id, :user_id
  end

  def self.down
    rename_column :acts, :user_id, :player_id

    remove_index :users, :column => :remember_token
    remove_index :users, :column => :email
    remove_index :users, :column => :demo_id

    change_table(:users) do |t|
      t.remove :encrypted_password
      t.remove :salt
      t.remove :remember_token
    end

    rename_table :users, :players

    add_index :players, :demo_id
  end
end
