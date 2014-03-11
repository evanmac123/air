class ChangeDemosPublicByDefault < ActiveRecord::Migration
  def up
    change_column_default(:demos, :is_public, true)
  end

  def down
    change_column_default(:demos, :is_public, false)
  end
end
