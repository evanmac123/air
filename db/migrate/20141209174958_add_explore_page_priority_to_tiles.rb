class AddExplorePagePriorityToTiles < ActiveRecord::Migration
  def change
    add_column :tiles, :explore_page_priority, :integer
  end
end
