class AddVictoryVerificationEmailAndPhoneToDemo < ActiveRecord::Migration
  def self.up
    add_column :demos, :victory_verification_email, :string
    add_column :demos, :victory_verification_sms_number, :string
  end

  def self.down
    remove_column :demos, :victory_verification_sms_number
    remove_column :demos, :victory_verification_email
  end
end
