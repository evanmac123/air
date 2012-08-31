class AddCustomAlreadyClaimedMessageToDemos < ActiveRecord::Migration
  def change
    add_column :demos, :custom_already_claimed_message, :string
  end
end
