class AddNotShowOnboardingToBoardMemberships < ActiveRecord::Migration
  def change
  	add_column :board_memberships, :not_show_onboarding, :boolean, default: false
  end
end
