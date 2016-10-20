class CreateUserOnboardings < ActiveRecord::Migration
  def change
    create_table :user_onboardings do |t|
      t.references :user
      t.references :onboarding
      t.string :state

      t.timestamps
    end
    add_index :user_onboardings, :user_id
    add_index :user_onboardings, :onboarding_id
  end
end
