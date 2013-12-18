class MakeTileAndActUsersPolymorphic < ActiveRecord::Migration
  def up
    # Make these associations polymorphic
    add_column :tile_completions, :user_type, :string
    add_column :acts, :user_type, :string
    execute "UPDATE tile_completions SET user_type='User'"
    execute "UPDATE acts SET user_type='User'"

    add_index :tile_completions, :user_type
    add_index :acts, :user_type
  end

  def down
    remove_column :tile_completions, :user_type 
    remove_column :acts, :user_type
  end
end
