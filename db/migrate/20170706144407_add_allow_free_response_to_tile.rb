class AddAllowFreeResponseToTile < ActiveRecord::Migration
  def change
    add_column :tiles, :allow_free_response, :boolean, default: false
  end
end
