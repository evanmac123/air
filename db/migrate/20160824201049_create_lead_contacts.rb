class CreateLeadContacts < ActiveRecord::Migration
  def change
    create_table :lead_contacts do |t|
      t.references :user
      t.string :email
      t.string :name
      t.string :phone
      t.string :role
      t.string :status
      t.string :source
      t.string :organization_name
      t.string :organization_size

      t.timestamps
    end
    add_index :lead_contacts, :user_id
    add_index :lead_contacts, :email
    add_index :lead_contacts, :status
  end
end
