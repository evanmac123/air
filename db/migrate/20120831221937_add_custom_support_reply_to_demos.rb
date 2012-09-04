class AddCustomSupportReplyToDemos < ActiveRecord::Migration
  def change
    add_column :demos, :custom_support_reply, :string
  end
end
