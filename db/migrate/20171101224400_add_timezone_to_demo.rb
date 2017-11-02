class AddTimezoneToDemo < ActiveRecord::Migration
  def change
    add_column :demos, :timezone, :string, default: "Eastern Time (US & Canada)"
  end
end
