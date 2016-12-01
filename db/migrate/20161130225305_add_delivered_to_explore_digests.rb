class AddDeliveredToExploreDigests < ActiveRecord::Migration
  def change
    add_column :explore_digests, :delivered, :boolean, default: false
  end
end
