class AddSlugToChannels < ActiveRecord::Migration
  def change
    add_column :channels, :slug, :string
    add_index :channels, :slug
  end
end
