class AddsReceivesSmsToUsers < ActiveRecord::Migration
  def up
    add_column :users, :receives_sms, :boolean, default: true
  end

  def down
    remove_column :users, :receives_sms
  end
end
