class AddIsPaidFlagToDemos < ActiveRecord::Migration
  def change
    add_column :demos, :is_paid, :boolean, default: false
  end
end
