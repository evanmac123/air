class AddCreatorIdToTiles < ActiveRecord::Migration
  def change
  	add_column :tiles, :creator_id, :integer
  end
end
