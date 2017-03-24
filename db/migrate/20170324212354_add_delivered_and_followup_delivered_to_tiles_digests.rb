class AddDeliveredAndFollowupDeliveredToTilesDigests < ActiveRecord::Migration
  def change
    add_column :tiles_digests, :delivered, :boolean, default: false
    add_column :tiles_digests, :followup_delivered, :boolean, default: false
  end
end
