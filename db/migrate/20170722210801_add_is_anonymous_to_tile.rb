class AddIsAnonymousToTile < ActiveRecord::Migration
  def change
    add_column :tiles, :is_anonymous, :boolean, default: false
  end
end
