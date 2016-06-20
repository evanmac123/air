class AddExploreEnabledToBoard < ActiveRecord::Migration
  def change
    add_column :demos, :explore_disabled, :boolean, default: true
  end
end
