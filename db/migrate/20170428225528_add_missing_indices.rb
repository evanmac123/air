class AddMissingIndices < ActiveRecord::Migration
  def change
    add_index :raffles, :demo_id
    add_index :demos, :dependent_board_id
    add_index :demos, :marked_for_deletion
    add_index :custom_color_palettes, :demo_id
  end
end
