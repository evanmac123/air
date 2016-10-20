class AddMoreInfoToUserOnboarding < ActiveRecord::Migration
  def change
    add_column :user_onboardings, :more_info, :string
  end
end
