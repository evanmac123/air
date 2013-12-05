class AddPublicSlugToDemos < ActiveRecord::Migration
  def change
    add_column :demos, :public_slug, :string
    add_index  :demos, :public_slug
  end
end
