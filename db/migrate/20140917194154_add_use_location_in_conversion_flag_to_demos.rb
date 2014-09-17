class AddUseLocationInConversionFlagToDemos < ActiveRecord::Migration
  def change
    add_column :demos, :use_location_in_conversion, :boolean, default: false
  end
end
