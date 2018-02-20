class AddPlanDateToTiles < ActiveRecord::Migration
  def change
    add_column :tiles, :plan_date, :date
  end
end
