class AddImageHeaderToChannels < ActiveRecord::Migration
  def change
    add_column :channels, :image_header, :string
  end
end
