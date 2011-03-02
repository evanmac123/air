class DowncaseEmailAddresses < ActiveRecord::Migration
  def self.up
    User.all.each do |user|
      user.email = user.email.downcase
      user.save!
    end
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
