class CreateSelfInvitingDomains < ActiveRecord::Migration
  def self.up
    create_table :self_inviting_domains do |t|
      t.string :domain, :null => false, :default => ''
      t.belongs_to :demo

      t.timestamps
    end

    add_index :self_inviting_domains, :domain
  end

  def self.down
    drop_table :self_inviting_domains
  end
end
