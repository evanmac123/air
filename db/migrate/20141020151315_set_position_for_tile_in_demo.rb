class SetPositionForTileInDemo < ActiveRecord::Migration
  def up
    Demo.all.each do |demo|
      Tile::STATUS.each do |status|
        demo.tiles \
            .where("status = ?", status) \
            .order('created_at ASC') \
            .each_with_index do |tile, index|
              
          tile.update_attribute(:position, index)
        end
      end
    end
  end

  def down
    Tile.update_all(position: nil)
  end
end
