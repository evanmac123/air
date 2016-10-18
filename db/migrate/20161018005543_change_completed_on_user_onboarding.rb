class ChangeCompletedOnUserOnboarding < ActiveRecord::Migration
  def up
    change_column :user_onboardings, :completed, "boolean USING CAST(completed AS boolean)", null: false, default: false
  end

  def down
    change_column :user_onboardings, :completed, :string
  end
end
