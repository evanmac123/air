class CleanupUsers < ActiveRecord::Migration
  def up
    remove_column :users, :last_told_about_mute
    remove_column :users, :suppress_mute_notice
    remove_column :users, :mt_texts_today
    remove_column :users, :follow_up_message_sent_at
    remove_column :users, :flashes_for_next_request
    remove_column :users, :ssn_hash
    remove_index :users, :ssn_hash
    remove_column :users, :is_employee
    remove_index :users, :is_employee
    remove_column :users, :sample_tile_completed
    remove_column :users, :displayed_tile_post_guide
    remove_column :users, :displayed_tile_success_guide
    remove_column :users, :displayed_active_tile_guide
    remove_column :users, :displayed_activity_page_admin_guide
    remove_column :users, :share_section_intro_seen
    remove_column :users, :last_unmonitored_mailbox_response_at
    remove_column :users, :submitted_tile_menu_intro_seen
    remove_column :users, :won_at
    remove_column :users, :last_suggested_items
    remove_column :users, :ranking_query_offset
  end

  def down
    add_column :users, :last_told_about_mute, :timestamp
    add_column :users, :suppress_mute_notice, :boolean, :default => false
    add_column :users, :mt_texts_today, :integer, :null => false, :default => 0
    add_column :users, :follow_up_message_sent_at, :timestamp
    add_column :users, :flashes_for_next_request, :text
    add_column :users, :ssn_hash, :string
    add_column :users, :is_employee, :boolean, :default => true
    add_index :users, :is_employee
    add_column :users, :sample_tile_completed, :boolean
    add_column :users, :displayed_tile_post_guide, :boolean, default: false
    add_column :users, :displayed_tile_success_guide, :boolean, default: false
    add_column :users, :displayed_active_tile_guide, :boolean, default: false

    add_column :users, :displayed_activity_page_admin_guide, :boolean, default: false
    execute "UPDATE users SET displayed_activity_page_admin_guide = true"

    add_column :users, :share_section_intro_seen, :boolean
    add_column :users, :last_unmonitored_mailbox_response_at, :datetime
    add_column :users, :submitted_tile_menu_intro_seen, :boolean, default: false, null: false

    add_column :users, :won_at, :datetime

    add_column :users, :last_suggested_items, :string, :null => false, :default => ''

    add_column :users, :ranking_query_offset, :integer
  end
end
