class CreateRawSms < ActiveRecord::Migration
  def self.up
    create_table :raw_sms do |t|
      t.string :from
      t.string :body
      t.string :twilio_sid
      t.timestamps
    end
  end

  def self.down
    drop_table :raw_sms
  end
end
