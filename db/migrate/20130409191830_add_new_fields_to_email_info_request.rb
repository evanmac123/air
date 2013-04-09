class AddNewFieldsToEmailInfoRequest < ActiveRecord::Migration
  def change
    add_column :email_info_requests, :role,    :string
    add_column :email_info_requests, :size,    :string
    add_column :email_info_requests, :company, :string
  end
end
