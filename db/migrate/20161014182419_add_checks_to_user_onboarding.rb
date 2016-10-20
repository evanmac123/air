class AddChecksToUserOnboarding < ActiveRecord::Migration
  def change
    add_column :user_onboardings, :demo_scheduled, :boolean, null: false, default: false
    add_column :user_onboardings, :shared, :boolean, null: false, default: false
  end
end
