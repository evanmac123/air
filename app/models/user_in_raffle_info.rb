class UserInRaffleInfo < ActiveRecord::Base
  belongs_to :user, polymorphic: true
  belongs_to :raffle

  def self.find_user_in_raffle_info raffle, user
    self.transaction do
      user_in_raffle = self.where(raffle_id: raffle.id, user_id: user.id, user_type: user.class.name.to_s).first
      unless user_in_raffle
        user_in_raffle = UserInRaffleInfo.create(raffle_id: raffle.id, user_id: user.id, user_type: user.class.name.to_s) 
      end
      user_in_raffle
    end
  end

  def self.add_blacklisted_participants raffle, users
    update_array raffle, users, {is_winner: false, in_blacklist: true}
  end

  def self.add_winners raffle, users
    update_array raffle, users, {is_winner: true, in_blacklist: false}
  end

  def self.delete_winners raffle, users
    update_array raffle, users, {is_winner: false}
  end

  def self.update_array raffle, users, attributes = {}
    users = make_array users
    users.each do |user|
      user_in_raffle = self.find_user_in_raffle_info raffle, user
      user_in_raffle.update_attributes(attributes)
    end
  end

  def self.make_array users
    unless users.class == Array
      user = users
      users = []
      users.push user
    end
    users
  end
end
