class AddClaimCodeToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :claim_code, :string
    add_index :users, :claim_code
  end

  def self.down
    remove_index :users, :claim_code
    remove_column :users, :claim_code
  end
end
