class AddTrigramIndexToLocationName < ActiveRecord::Migration
  def up
    execute "commit" # ditch the transaction that this migration runs in
                     # so that we can create indices concurrently

    execute "CREATE INDEX CONCURRENTLY location_name_trigram on locations USING gin (name gin_trgm_ops)"
  end

  def down
    execute "DROP INDEX location_name_trigram"
  end
end
