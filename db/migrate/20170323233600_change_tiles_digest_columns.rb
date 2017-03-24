class ChangeTilesDigestColumns < ActiveRecord::Migration
  def up
    remove_column :tiles_digests, :only_joined_users
    add_column :tiles_digests, :include_unclaimed_users, :boolean
  end

  def down
    remove_column :tiles_digests, :include_unclaimed_users
    add_column :tiles_digests, :only_joined_users, :boolean
  end
end
