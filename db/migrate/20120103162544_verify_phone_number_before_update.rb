class VerifyPhoneNumberBeforeUpdate < ActiveRecord::Migration
  def self.up
    add_column :users, :new_phone_number, :string, :null => false, :default => ''
    add_column :users, :new_phone_validation, :string, :null => false, :default => ''
  end

  def self.down
    remove_column :users, :new_phone_number, :new_phone_validation
  end
end
