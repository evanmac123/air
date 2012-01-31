class SetSlugToSmsSlug < ActiveRecord::Migration
  def self.up
    execute "UPDATE users SET slug = sms_slug WHERE sms_slug != ''"
  end

  def self.down
  end
end
