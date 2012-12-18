class AddLimitsPerDayToTags < ActiveRecord::Migration
  def change
    add_column :tags, :daily_limit, :integer
  end
end
