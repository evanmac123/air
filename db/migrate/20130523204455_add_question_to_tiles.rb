class AddQuestionToTiles < ActiveRecord::Migration
  def change
    add_column :tiles, :question, :string, :default => ''
  end
end
