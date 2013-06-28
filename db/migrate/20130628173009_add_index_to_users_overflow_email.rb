class AddIndexToUsersOverflowEmail < ActiveRecord::Migration
  def change
    add_index :users, :overflow_email
  end
end
