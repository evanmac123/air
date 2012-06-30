class RemovedUniqueEmailConstraint < ActiveRecord::Migration
  def up
    # execute "ALTER TABLE users DROP CONSTRAINT IF EXISTS email_unique"
    execute "ALTER TABLE users DROP CONSTRAINT email_unique"
    execute "DROP INDEX IF EXISTS email_unique"
  end

  def down
    execute "ALTER TABLE users ADD CONSTRAINT email_unique UNIQUE(email)"
  end
end
