class AddMultipleChoiceColumnsToTiles < ActiveRecord::Migration
  def change
    add_column :tiles, :correct_answer_index, :integer
  end
end
