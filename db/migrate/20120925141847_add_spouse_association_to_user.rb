class AddSpouseAssociationToUser < ActiveRecord::Migration
  def change
    add_column :users, :spouse_id, :integer
    add_index :users, :spouse_id
  end
end
