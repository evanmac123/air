class RenameActedAt < ActiveRecord::Migration
  def up
    rename_column :users, :acted_at, :last_acted_at
  end

  def down
    rename_column :users, :last_acted_at, :acted_at
  end
end
