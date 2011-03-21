class RemoveThreadIdFromBadMessages < ActiveRecord::Migration
  def self.up
    remove_column :bad_messages, :thread_id
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
