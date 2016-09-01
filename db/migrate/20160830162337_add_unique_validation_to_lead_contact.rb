class AddUniqueValidationToLeadContact < ActiveRecord::Migration
  def change
    remove_index :lead_contacts, :email
    add_index :lead_contacts, :email, :unique => true
  end
end
