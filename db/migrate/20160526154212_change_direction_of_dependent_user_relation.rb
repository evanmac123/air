class ChangeDirectionOfDependentUserRelation < ActiveRecord::Migration
  def change
    rename_column :users, :dependent_user_id, :primary_user_id
  end

end
