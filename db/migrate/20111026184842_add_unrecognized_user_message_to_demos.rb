class AddUnrecognizedUserMessageToDemos < ActiveRecord::Migration
  def self.up
    add_column :demos, :unrecognized_user_message, :string
  end

  def self.down
    remove_column :demos, :unrecognized_user_message
  end
end
