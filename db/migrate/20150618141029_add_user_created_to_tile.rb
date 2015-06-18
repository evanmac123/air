class AddUserCreatedToTile < ActiveRecord::Migration
  def change
    add_column :tiles, :user_created, :boolean
  end
end
