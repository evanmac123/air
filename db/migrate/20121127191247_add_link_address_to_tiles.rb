class AddLinkAddressToTiles < ActiveRecord::Migration
  def change
    add_column :tiles, :link_address, :string, :default => ''
  end
end
