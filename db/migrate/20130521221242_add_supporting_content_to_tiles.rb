class AddSupportingContentToTiles < ActiveRecord::Migration
  def change
    add_column :tiles, :supporting_content, :string, default: ""
  end
end
