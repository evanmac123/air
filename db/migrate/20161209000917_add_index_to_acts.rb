class AddIndexToActs < ActiveRecord::Migration
  def change
    add_index :acts, :hidden
  end
end
