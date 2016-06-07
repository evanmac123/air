class AddDependentBoardIdToDemo < ActiveRecord::Migration
  def change
    add_column :demos, :dependent_board_id, :integer
  end
end
