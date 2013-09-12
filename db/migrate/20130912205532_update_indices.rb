class UpdateIndices < ActiveRecord::Migration
  def up
    add_index :acts, :referring_user_id
    add_index :characteristics, :demo_id
    add_index :claim_state_machines, :demo_id
    add_index :email_commands, :user_id
    add_index :labels, [:rule_id, :tag_id]
    add_index :more_info_requests, :user_id
    add_index :outgoing_sms, :mate_id
    add_index :payments, [:demo_id, :user_id]
    add_index :rules, [:goal_id, :primary_tag_id]
    add_index :skins, :demo_id
    add_index :suggestions, :user_id
    add_index :timed_bonus, [:demo_id, :user_id]
    add_index :tutorials, :user_id
    add_index :unsubscribes, :user_id

    remove_index :tiles, name: :index_suggested_tasks_on_start_time
  end

  def down
    remove_index :acts, :referring_user_id
    remove_index :characteristics, :demo_id
    remove_index :claim_state_machines, :demo_id
    remove_index :email_commands, :user_id
    remove_index :labels, [:rule_id, :tag_id]
    remove_index :more_info_requests, :user_id
    remove_index :outgoing_sms, :mate_id
    remove_index :payments, [:demo_id, :user_id]
    remove_index :rules, [:goal_id, :primary_tag_id]
    remove_index :skins, :demo_id
    remove_index :suggestions, :user_id
    remove_index :timed_bonus, [:demo_id, :user_id]
    remove_index :tutorials, :user_id
    remove_index :unsubscribes, :user_id
  end
end
