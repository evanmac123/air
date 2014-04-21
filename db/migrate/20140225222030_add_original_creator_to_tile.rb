class AddOriginalCreatorToTile < ActiveRecord::Migration
  def change
    add_column :tiles, :original_creator_id, :integer
  end
end
