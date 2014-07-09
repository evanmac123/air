class AddNotShowOnboardingToUsers < ActiveRecord::Migration
  def change
  	add_column :users, :not_show_onboarding, :boolean, default: false
  end
end
