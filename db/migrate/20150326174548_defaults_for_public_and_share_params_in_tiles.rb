class DefaultsForPublicAndShareParamsInTiles < ActiveRecord::Migration
  def up
  	change_column :tiles, :is_public, :boolean, null: false
  	change_column :tiles, :is_copyable, :boolean, null: false
  	change_column :tiles, :is_sharable, :boolean, null: false, default: false
  end

  def down
  	change_column :tiles, :is_public, :boolean, null: true
  	change_column :tiles, :is_copyable, :boolean, null: true
  	change_column :tiles, :is_sharable, :boolean, null: true, default: nil
  end
end
