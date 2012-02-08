class AddMuteNoticeThresholdToDemos < ActiveRecord::Migration
  def self.up
    add_column :demos, :mute_notice_threshold, :integer
  end

  def self.down
    remove_column :demos, :mute_notice_threshold
  end
end
