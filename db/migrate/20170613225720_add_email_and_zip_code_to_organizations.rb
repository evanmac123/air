class AddEmailAndZipCodeToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :email, :string
    add_column :organizations, :zip_code, :string
  end
end
