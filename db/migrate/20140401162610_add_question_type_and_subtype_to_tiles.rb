class AddQuestionTypeAndSubtypeToTiles < ActiveRecord::Migration
  def change
  	add_column :tiles, :question_type, :string
  	add_column :tiles, :question_subtype, :string
  end
end
