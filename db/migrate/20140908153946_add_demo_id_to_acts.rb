class AddDemoIdToActs < ActiveRecord::Migration
  def change
    add_index :acts, :demo_id
  end
end
