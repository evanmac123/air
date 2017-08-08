class AddFileAttachmentsToTile < ActiveRecord::Migration
  def change
    add_column :tiles, :file_attachments, :text
  end
end
