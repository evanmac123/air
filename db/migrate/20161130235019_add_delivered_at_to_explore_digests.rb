class AddDeliveredAtToExploreDigests < ActiveRecord::Migration
  def change
    add_column :explore_digests, :delivered_at, :datetime
  end
end
