class AddGameReferrerColumns < ActiveRecord::Migration
  def self.up
    add_column :demos, :credit_game_referrer_threshold, :integer
    add_column :demos, :game_referrer_bonus, :integer
    add_column :users, :accepted_invitation_at, :datetime
    add_column :users, :game_referrer_id, :integer

    User.reset_column_information
    User.all.each {|u| u.update_attribute(:accepted_invitation_at, Time.now)}
  end

  def self.down
    remove_column :users, :game_referrer_id
    remove_column :users, :accepted_invitation_at
    remove_column :demos, :game_referrer_bonus
    remove_column :demos, :credit_game_referrer_threshold
  end
end
