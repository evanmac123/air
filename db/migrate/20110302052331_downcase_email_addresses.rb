class DowncaseEmailAddresses < ActiveRecord::Migration
  def self.up
    users = select_all "select * from users"
    
    users.each do |user|
      update "update users set email = #{quote(user['email'].downcase)} where id = #{user['id']}"
    end
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
