class EmbiggenCustomLoginMessage < ActiveRecord::Migration
  def self.up
    change_column :demos, :login_announcement, :string, :limit => 500
  end

  def self.down
    change_column :demos, :login_announcement, :string, :limit => 255
  end
end
