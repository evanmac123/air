class AddFollowUpDigestEmailToDemo < ActiveRecord::Migration

  class Demo < ActiveRecord::Base ; end

  def up
    add_column :demos, :follow_up_digest_email_days, :integer

    Demo.reset_column_information
    Demo.update_all follow_up_digest_email_days: 0
  end

  def down
    remove_column :demos, :follow_up_digest_email_days
  end
end
