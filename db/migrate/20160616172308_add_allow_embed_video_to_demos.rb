class AddAllowEmbedVideoToDemos < ActiveRecord::Migration
  def change
    add_column :demos, :allow_embed_video, :boolean, :default => false
  end
end
