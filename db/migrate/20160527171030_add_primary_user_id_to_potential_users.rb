class AddPrimaryUserIdToPotentialUsers < ActiveRecord::Migration
  def change
    add_column :potential_users, :primary_user_id, :integer
  end
end
