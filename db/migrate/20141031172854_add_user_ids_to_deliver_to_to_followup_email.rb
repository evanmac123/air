class AddUserIdsToDeliverToToFollowupEmail < ActiveRecord::Migration
  def change
    add_column :follow_up_digest_emails, :user_ids_to_deliver_to, :text
  end
end
