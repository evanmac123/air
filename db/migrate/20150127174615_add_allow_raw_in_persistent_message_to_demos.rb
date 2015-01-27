class AddAllowRawInPersistentMessageToDemos < ActiveRecord::Migration
  def change
    add_column :demos, :allow_raw_in_persistent_message, :boolean, default: false
  end
end
