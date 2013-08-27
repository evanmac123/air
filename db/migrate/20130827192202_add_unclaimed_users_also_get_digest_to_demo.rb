class AddUnclaimedUsersAlsoGetDigestToDemo < ActiveRecord::Migration
  def change
    add_column :demos, :unclaimed_users_also_get_digest, :boolean, :default => true
    execute "UPDATE demos SET unclaimed_users_also_get_digest=true"
  end
end
