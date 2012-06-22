class RemovedUniqueEmailConstraint < ActiveRecord::Migration
  def up
    execute "ALTER TABLE users DROP CONSTRAINT email_unique"
  end

  def down
    execute "ALTER TABLE users ADD CONSTRAINT email_unique UNIQUE(email)"
  end
end
