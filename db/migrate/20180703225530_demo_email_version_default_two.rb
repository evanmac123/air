class DemoEmailVersionDefaultTwo < ActiveRecord::Migration
  def change
    change_column_default :demos, :email_version, 2
  end
end
