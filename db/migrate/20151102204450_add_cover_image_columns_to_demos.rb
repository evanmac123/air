class AddCoverImageColumnsToDemos < ActiveRecord::Migration
  def up
    add_attachment :demos, :cover_image
  end

  def down
    remove_attachment :demos, :cover_image
  end
end
