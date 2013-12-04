class TilesQuestionAndLinkAddressToText < ActiveRecord::Migration
  def up
    change_column :tiles, :question, :text
    change_column :tiles, :link_address, :text
  end

  def down
    change_column :tiles, :question, :string, limit: 255
    change_column :tiles, :link_address, :string, limit: 255
  end
end
