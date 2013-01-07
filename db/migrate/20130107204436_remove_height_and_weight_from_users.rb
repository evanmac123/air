class RemoveHeightAndWeightFromUsers < ActiveRecord::Migration
  def up
    remove_column :users, :weight
    remove_column :users, :height
  end

  def down
    add_column :users, :height, :integer
    add_column :users, :weight, :integer
  end
end
