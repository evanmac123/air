class AddIsPublicToDemos < ActiveRecord::Migration
  def change
    add_column :demos, :is_public, :boolean, default: false
  end
end
