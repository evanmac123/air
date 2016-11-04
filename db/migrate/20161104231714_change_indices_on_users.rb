class ChangeIndicesOnUsers < ActiveRecord::Migration
  def up
    remove_index :users, [:official_email]

    add_index :users, [:official_email], unique: true
    add_index :users, [:email], unique: true
    add_index :users, [:name]
  end

  def down
    remove_index :users, [:official_email], unique: true
    remove_index :users, [:email], unique: true
    remove_index :users, [:name]

    add_index :users, [:official_email], name: "index_users_on_official_email"
  end
end
