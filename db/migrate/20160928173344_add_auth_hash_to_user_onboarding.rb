class AddAuthHashToUserOnboarding < ActiveRecord::Migration
  def change
    add_column :user_onboardings, :auth_hash, :string
  end
end
