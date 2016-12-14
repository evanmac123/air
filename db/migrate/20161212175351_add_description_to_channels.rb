class AddDescriptionToChannels < ActiveRecord::Migration
  def change
    add_column :channels, :description, :string
  end
end
