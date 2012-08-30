class AddSsnHashToUsers < ActiveRecord::Migration
  def change
    add_column :users, :ssn_hash, :string
    add_index :users, :ssn_hash
  end
end
