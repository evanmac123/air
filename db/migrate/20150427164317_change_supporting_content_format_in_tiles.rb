class ChangeSupportingContentFormatInTiles < ActiveRecord::Migration
  def up
  	change_column :tiles, :supporting_content, :text
  end

  def down
  	change_column :tiles, :supporting_content, :string
  end
end
