class AddMediaSourceToTiles < ActiveRecord::Migration
  def change
    add_column :tiles, :media_source, :string
  end
end
