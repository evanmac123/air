class AddDefaultsAndCommentToEmailRequest < ActiveRecord::Migration
  def self.up
    change_column :email_info_requests, :name, :string, :default => '(name not entered)'
    change_column :email_info_requests, :email, :string, :default => '(email not entered)'
    add_column    :email_info_requests, :comment, :string, :default => ''
  end

  def self.down
    remove_column :email_info_requests, :comment
    change_column :email_info_requests, :email, :string
    change_column :email_info_requests, :name, :string
  end
end
