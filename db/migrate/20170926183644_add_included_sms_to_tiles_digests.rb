class AddIncludedSmsToTilesDigests < ActiveRecord::Migration
  def change
    add_column :tiles_digests, :include_sms, :boolean, default: false
  end
end
