class AddCustomReplyEmailNameToDemo < ActiveRecord::Migration
  def change
    add_column :demos, :custom_reply_email_name, :string
  end
end
