class AddCompletedToUserOnboarding < ActiveRecord::Migration
  def change
    add_column :user_onboardings, :completed, :boolean, null: false, default: false
  end
end
