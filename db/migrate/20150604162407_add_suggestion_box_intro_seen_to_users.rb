class AddSuggestionBoxIntroSeenToUsers < ActiveRecord::Migration
  def change
    add_column :users, :suggestion_box_intro_seen, :boolean, default: false, null: false
  end
end
