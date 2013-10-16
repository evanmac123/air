class RemoveFollowUpDigestEmailDaysFromDemo < ActiveRecord::Migration
  def up
    remove_column :demos, :follow_up_digest_email_days
  end

  def down
    add_column :demos, :follow_up_digest_email_days, :integer
  end
end
