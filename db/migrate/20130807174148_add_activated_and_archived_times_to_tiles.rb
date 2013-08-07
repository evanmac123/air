class AddActivatedAndArchivedTimesToTiles < ActiveRecord::Migration
  def change
    add_column :tiles, :activated_at, :datetime
    add_column :tiles, :archived_at, :datetime
  end
end
