class AddCancelAccountTokenToUsers < ActiveRecord::Migration
  def change
    add_column :users, :cancel_account_token, :string
    add_index :users, :cancel_account_token
  end
end
