class AddNormalizedNameToLocation < ActiveRecord::Migration
  def change
    add_column :locations, :normalized_name, :string
    execute "CREATE INDEX location_normalized_name_trigram on locations USING gin (normalized_name gin_trgm_ops)"
  end
end
