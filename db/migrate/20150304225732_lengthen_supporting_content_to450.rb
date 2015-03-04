class LengthenSupportingContentTo450 < ActiveRecord::Migration
  def up
    change_column :tiles, :supporting_content, :string, limit: 450
  end

  def down
    change_column :tiles, :supporting_content, :string, limit: 300
  end
end
