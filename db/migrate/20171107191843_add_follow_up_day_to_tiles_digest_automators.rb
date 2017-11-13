class AddFollowUpDayToTilesDigestAutomators < ActiveRecord::Migration
  def change
    add_column :tiles_digest_automators, :has_follow_up, :boolean, default: true
    add_column :tiles_digest_automators, :include_sms, :boolean, default: false
    add_column :tiles_digest_automators, :include_unclaimed_users, :boolean, default: true
  end
end
