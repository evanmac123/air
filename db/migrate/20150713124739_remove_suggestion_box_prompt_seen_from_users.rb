class RemoveSuggestionBoxPromptSeenFromUsers < ActiveRecord::Migration
  def up
    remove_column :users, :suggestion_box_prompt_seen
  end

  def down
    add_column :users, :suggestion_box_prompt_seen, :boolean, default: false, null: false
  end
end
