class RemoveSelfInvitingDomainsCompletely < ActiveRecord::Migration
  def self.up
    remove_index :self_inviting_domains, :domain
    drop_table :self_inviting_domains
  end

  def self.down
    create_table :self_inviting_domains do |t|
      t.string :domain, :null => false, :default => ''
      t.belongs_to :demo

      t.timestamps
    end

    add_index :self_inviting_domains, :domain
  end
end
