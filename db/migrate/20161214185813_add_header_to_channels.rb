class AddHeaderToChannels < ActiveRecord::Migration
  def change
    add_column :channels, :header, :string
  end
end
