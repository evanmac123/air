class AddLaunchDateToDemos < ActiveRecord::Migration
  def change
    add_column :demos, :launch_date, :date
  end
end
