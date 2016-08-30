class AddDefaultFalseToorganization < ActiveRecord::Migration
  def up
    change_column :organizations, :is_hrm, :boolean, default: false
  end

  def down
  end
end
