class AddIsParentToDemos < ActiveRecord::Migration
  def change
  	add_column :demos, :is_parent, :boolean, null: false, default: false
  end
end
