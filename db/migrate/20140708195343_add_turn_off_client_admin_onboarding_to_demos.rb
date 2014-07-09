class AddTurnOffClientAdminOnboardingToDemos < ActiveRecord::Migration
  def change
  	add_column :demos, :turn_off_client_admin_onboarding, :boolean, default: false
  end
end
