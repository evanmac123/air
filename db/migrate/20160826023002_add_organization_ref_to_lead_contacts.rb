class AddOrganizationRefToLeadContacts < ActiveRecord::Migration
  def change
    add_column :lead_contacts, :organization_id, :integer
    add_index  :lead_contacts, :organization_id
  end
end
