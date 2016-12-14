class AddRankToChannels < ActiveRecord::Migration
  def change
    add_column :channels, :rank, :integer, default: 0
  end
end
