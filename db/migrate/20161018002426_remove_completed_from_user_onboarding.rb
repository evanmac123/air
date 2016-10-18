class RemoveCompletedFromUserOnboarding < ActiveRecord::Migration
  def up
    remove_column :user_onboardings, :completed
  end

  def down
    add_column :user_onboardings, :completed, :string
  end
end
