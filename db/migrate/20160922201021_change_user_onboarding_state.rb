class ChangeUserOnboardingState < ActiveRecord::Migration
  def up
    change_column :user_onboardings, :state, "integer USING CAST(state AS integer)", default: 2
  end

  def down
    change_column :user_onboardings, :state, :string
  end
end
