class AddModalSuppressionToDemos < ActiveRecord::Migration
  def change
    add_column :demos, :guest_user_conversion_modal, :boolean, default: true
  end
end
