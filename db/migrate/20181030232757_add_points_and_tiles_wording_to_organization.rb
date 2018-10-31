class AddPointsAndTilesWordingToOrganization < ActiveRecord::Migration
  def change
    add_column :organizations, :tiles_wording, :string
    add_column :organizations, :points_wording, :string
  end
end
