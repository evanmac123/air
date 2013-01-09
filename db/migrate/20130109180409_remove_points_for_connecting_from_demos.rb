class RemovePointsForConnectingFromDemos < ActiveRecord::Migration
  def up
    remove_column :demos, :points_for_connecting
  end

  def down
    add_column :demos, :points_for_connecting, :integer
  end
end
