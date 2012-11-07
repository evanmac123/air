class RemoveVictoryRelatedFieldsFromDemo < ActiveRecord::Migration
  def up
    remove_column :demos, :victory_threshold
    remove_column :demos, :custom_victory_achievement_message
    remove_column :demos, :custom_victory_sms
    remove_column :demos, :custom_victory_scoreboard_message
    remove_column :demos, :victory_verification_sms_number
    remove_column :demos, :victory_verification_email

    drop_table :wins
  end

  def down
    add_column :demos, :victory_threshold, :integer
    add_column :demos, :custom_victory_achievement_message, :string
    add_column :demos, :custom_victory_sms, :string, :limit => 150
    add_column :demos, :custom_victory_scoreboard_message, :string
    add_column :demos, :victory_verification_sms_number, :string
    add_column :demos, :victory_verification_email, :string

    create_table :wins do |t|
      t.belongs_to :demo
      t.belongs_to :user

      t.timestamps
    end

    add_index :wins, :demo_id
    add_index :wins, :user_id
  end
end
