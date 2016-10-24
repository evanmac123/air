class AddCompletedToUserOnboarding < ActiveRecord::Migration
  def change
    add_column :user_onboardings, :completed, :string
  end
end
