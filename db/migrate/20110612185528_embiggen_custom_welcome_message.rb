class EmbiggenCustomWelcomeMessage < ActiveRecord::Migration
  def self.up
    change_column :demos, :custom_welcome_message, :string, :limit => 160
  end

  def self.down
    change_column :demos, :custom_welcome_message, :string, :limit => 140
  end
end
