class AddAnswerIndexToTileCompletions < ActiveRecord::Migration
  def change
  	add_column :tile_completions, :answer_index, :integer
  end
end
