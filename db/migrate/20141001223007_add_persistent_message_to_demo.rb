class AddPersistentMessageToDemo < ActiveRecord::Migration
  def change
    add_column :demos, :persistent_message, :string, default: ''
  end
end
