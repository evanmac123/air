class AddTopicToOnboarding < ActiveRecord::Migration
  def change
    add_column :onboardings, :topic_name, :string
  end
end
