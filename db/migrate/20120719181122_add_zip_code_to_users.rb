class AddZipCodeToUsers < ActiveRecord::Migration
  def change
    add_column :users, :zip_code, :string, :length => 9
    add_index :users, :zip_code
  end
end
