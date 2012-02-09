class AddUniquenessConstraintToUserEmail < ActiveRecord::Migration
  def self.up
    execute "ALTER TABLE users ADD CONSTRAINT email_unique UNIQUE(email)"
  end

  def self.down
    execute "ALTER TABLE users DROP CONSTRAINT email_unique"
  end
end
