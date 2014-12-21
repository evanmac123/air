class AddAttachmentLogoToDemos < ActiveRecord::Migration
  def self.up
    change_table :demos do |t|
      t.has_attached_file :logo
    end
  end

  def self.down
    drop_attached_file :demos, :logo
  end
end
