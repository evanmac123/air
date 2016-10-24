class AddIsExploreToTopic < ActiveRecord::Migration
  def change
    add_column :topics, :is_explore, :boolean, null: false, default: true
  end
end
