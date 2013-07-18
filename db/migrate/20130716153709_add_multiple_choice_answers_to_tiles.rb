class AddMultipleChoiceAnswersToTiles < ActiveRecord::Migration
  def change
    add_column :tiles, :multiple_choice_answers, :text
  end
end
