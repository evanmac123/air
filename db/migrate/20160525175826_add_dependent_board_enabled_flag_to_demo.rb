class AddDependentBoardEnabledFlagToDemo < ActiveRecord::Migration
  def change
    add_column :demos, :dependent_board_enabled, :boolean, default: false
  end
end
