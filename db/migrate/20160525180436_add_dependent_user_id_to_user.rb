class AddDependentUserIdToUser < ActiveRecord::Migration
  def change
    add_column :users, :dependent_user_id, :integer
  end
end
