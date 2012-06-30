class AddedPhoneNumberToEmailInfoRequest < ActiveRecord::Migration
  def up
    add_column :email_info_requests, :phone, :string
  end

  def down
    remove_columns :email_info_requests, :phone
  end
end
