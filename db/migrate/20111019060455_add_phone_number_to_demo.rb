class AddPhoneNumberToDemo < ActiveRecord::Migration
  def self.up
    add_column :demos, :phone_number, :string
  end

  def self.down
    remove_column :demos, :phone_number
  end
end
