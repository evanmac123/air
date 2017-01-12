class AddColumnsToOrganization < ActiveRecord::Migration
  def change
    add_column :organizations, :internal, :boolean, default: false
  end
end
