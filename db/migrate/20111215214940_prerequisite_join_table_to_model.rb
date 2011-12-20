class PrerequisiteJoinTableToModel < ActiveRecord::Migration
  def self.up
    execute "CREATE SEQUENCE prerequisites_id_seq"
    add_column :prerequisites, :id, :integer
    execute "ALTER TABLE prerequisites ALTER COLUMN id SET DEFAULT nextval('prerequisites_id_seq')"
    execute "UPDATE prerequisites SET id=nextval('prerequisites_id_seq')"
    execute "ALTER TABLE prerequisites ADD PRIMARY KEY (id)"

    rename_column :prerequisites, :prerequisite_id, :prerequisite_task_id
  end

  def self.down
    rename_column :prerequisites, :prerequisite_task_id, :prerequisite_id
    remove_column :prerequisites, :id
    execute "DROP SEQUENCE prerequisites_id_seq"
  end
end
