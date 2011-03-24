class AddInherentPointsToAct < ActiveRecord::Migration
  def self.up
    add_column :acts, :inherent_points, :integer
  end

  def self.down
    remove_column :acts, :inherent_points
  end
end
