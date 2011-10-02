class AddUseStandardPlaybookToDemos < ActiveRecord::Migration
  def self.up
    add_column :demos, :use_standard_playbook, :boolean
    execute "UPDATE demos SET use_standard_playbook = true"
    change_column :demos, :use_standard_playbook, :boolean, :null => false, :default => true
  end

  def self.down
    remove_column :demos, :use_standard_playbook
  end
end
