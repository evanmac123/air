class IncreaseSizeOfTileSupportingContent < ActiveRecord::Migration
  def up
    change_column :tiles, :supporting_content, :string, limit: 300
  end

  def down
    change_column :tiles, :supporting_content, :string, limit: 255
  end
end
