class AddPhoneNumberToPlayer < ActiveRecord::Migration
  def self.up
    add_column :players, :phone_number, :string, :default => "", :null => false
  end

  def self.down
    remove_column :players, :phone_number
  end
end
