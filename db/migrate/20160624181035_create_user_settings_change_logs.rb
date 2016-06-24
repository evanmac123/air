class CreateUserSettingsChangeLogs < ActiveRecord::Migration
  def change
    create_table :user_settings_change_logs do |t|
      t.references :user_id
      t.string :email, :default => "", :null => false
      t.string :email_token, :limit => 128

      t.timestamps
    end
    add_index :user_settings_change_logs, :user_id_id
  end
end
