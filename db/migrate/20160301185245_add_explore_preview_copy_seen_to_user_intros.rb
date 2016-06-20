class AddExplorePreviewCopySeenToUserIntros < ActiveRecord::Migration
  def change
    add_column :user_intros, :explore_preview_copy_seen, :boolean, default: false
  end
end
