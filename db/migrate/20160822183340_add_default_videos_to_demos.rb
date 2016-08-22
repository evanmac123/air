class AddDefaultVideosToDemos < ActiveRecord::Migration
  def change
    change_column :demos, :allow_embed_video, :boolean, :default => true
  end
end
