class AddManageAccessPromptSeenToUsers < ActiveRecord::Migration
  def change
    add_column :users, :manage_access_prompt_seen, :boolean, default: false, null: false
  end
end
