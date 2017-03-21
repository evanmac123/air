class AddMarkedForDeletionToDemos < ActiveRecord::Migration
  def change
    add_column :demos, :marked_for_deletion, :boolean, default: false
  end
end
