class AddEmailVersionToDemos < ActiveRecord::Migration
  def change
    add_column :demos, :email_version, :integer, default: 1
  end
end
