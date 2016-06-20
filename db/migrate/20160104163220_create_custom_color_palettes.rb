class CreateCustomColorPalettes < ActiveRecord::Migration
  def change
    create_table :custom_color_palettes do |t|
      t.integer :demo_id
      t.integer :company_id

      t.timestamps
    end
  end
end
