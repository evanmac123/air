class AddIsOnboardingToTopicBoard < ActiveRecord::Migration
  def change
    add_column :topic_boards, :is_onboarding, :boolean, null: false, default: false
  end
end
