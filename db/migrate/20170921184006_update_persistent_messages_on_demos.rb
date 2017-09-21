class UpdatePersistentMessagesOnDemos < ActiveRecord::Migration
  def up
    change_column :demos, :persistent_message, :text
  end

  def down
  end
end
