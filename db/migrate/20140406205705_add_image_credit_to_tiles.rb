class AddImageCreditToTiles < ActiveRecord::Migration
  def change
  	add_column :tiles, :image_credit, :text
  end
end
