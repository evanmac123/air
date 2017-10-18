class AddHideSocialToDemos < ActiveRecord::Migration
  def change
    add_column :demos, :hide_social, :boolean, default: false
  end
end
