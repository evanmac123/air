class ChangeCoverMessageToText < ActiveRecord::Migration
  def up
    change_column :demos, :cover_message, :text
  end

  def down
  end
end
