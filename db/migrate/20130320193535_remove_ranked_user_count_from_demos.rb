class RemoveRankedUserCountFromDemos < ActiveRecord::Migration
  def up
    remove_column :demos, :ranked_user_count
  end

  def down
    add_column :demos, :ranked_user_count, :integer, default: 0
  end
end
