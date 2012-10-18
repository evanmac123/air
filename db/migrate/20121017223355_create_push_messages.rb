class CreatePushMessages < ActiveRecord::Migration
  def change
    create_table :push_messages do |t|
      t.text :subject
      t.text :plain_text
      t.text :html_text
      t.string :sms_text, :limit => 160
      t.string :state, :default => 'scheduled'
      t.timestamp :scheduled_for
      t.text :email_recipient_ids
      t.text :sms_recipient_ids
      t.text :segment_description
      t.belongs_to :demo
      t.timestamps
    end
  end
end
