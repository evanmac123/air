class ChangeIsHrmDefaultToFalse < ActiveRecord::Migration
  def change
    change_column :organizations, :is_hrm, :boolean,  default: false
  end

end
