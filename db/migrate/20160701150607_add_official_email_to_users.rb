class AddOfficialEmailToUsers < ActiveRecord::Migration
  def change
    add_column :users, :official_email, :string
    add_index :users, :official_email
  end
end
