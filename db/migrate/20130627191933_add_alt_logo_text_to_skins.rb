class AddAltLogoTextToSkins < ActiveRecord::Migration
  def change
    add_column :skins, :alt_logo_text, :string
  end
end
