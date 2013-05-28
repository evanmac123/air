class AddStatusToTile < ActiveRecord::Migration
  # NOTE: 'update_all' does not instantiate the model and does not trigger ActiveRecord callbacks or validations
  def change
    add_column :tiles, :status, :string
    Tile.update_all status: 'active'
  end
end
