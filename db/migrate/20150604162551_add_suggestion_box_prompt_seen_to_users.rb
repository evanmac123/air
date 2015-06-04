class AddSuggestionBoxPromptSeenToUsers < ActiveRecord::Migration
  def change
    add_column :users, :suggestion_box_prompt_seen, :boolean, default: false, null: false
  end
end
