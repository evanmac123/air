class AddIndexesToUsers < ActiveRecord::Migration
  def up
    execute "commit" # this ends the transaction that this migration is wrapped in,
                     # since we can't create index concurrently within one. Yes, it's a
                     # hack.

    execute "CREATE EXTENSION IF NOT EXISTS pg_trgm"
    execute "CREATE INDEX CONCURRENTLY user_name_trigram on users USING gin (name gin_trgm_ops)"
    execute "CREATE INDEX CONCURRENTLY user_slug_trigram on users USING gin (slug gin_trgm_ops)"
    execute "CREATE INDEX CONCURRENTLY user_email_trigram on users USING gin (email gin_trgm_ops)"
  end

  def down
    execute "DROP EXTENSION pg_trgm CASCADE"
  end
end
