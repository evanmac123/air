class AddUploadInProgressToDemos < ActiveRecord::Migration
  def change
    add_column :demos, :upload_in_progress, :boolean
  end
end
