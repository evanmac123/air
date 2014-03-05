class CreateTileTags < ActiveRecord::Migration
  def change
    create_table :tile_tags do |t|
      t.string :title, default: ''
      t.timestamps
    end
  end
end
