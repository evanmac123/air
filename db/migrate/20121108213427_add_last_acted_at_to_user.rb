class AddLastActedAtToUser < ActiveRecord::Migration
  def up
    add_column :users, :acted_at, :datetime
  end

  def down 
    remove_columns :users, :acted_at
  end
end
