class AddSourceToEmailInfoRequests < ActiveRecord::Migration
  def change
    add_column :email_info_requests, :source, :string
  end
end
