class AddFeaturedToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :featured, :boolean
  end
end
