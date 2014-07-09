class AddTurnOffAdminOnboardingToDemos < ActiveRecord::Migration
  def change
  	add_column :demos, :turn_off_admin_onboarding, :boolean, default: false
  end
end
