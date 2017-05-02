class UserInRaffleInfo < ActiveRecord::Base
  belongs_to :user, polymorphic: true
  belongs_to :raffle
end
