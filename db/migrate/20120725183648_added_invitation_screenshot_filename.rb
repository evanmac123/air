class AddedInvitationScreenshotFilename < ActiveRecord::Migration
  def up
    add_column :demos, :invitation_screenshot_filename, :string, :null => false, :default => ''
  end

  def down
    remove_columns :demos, :invitation_screenshot_filename
  end
end
