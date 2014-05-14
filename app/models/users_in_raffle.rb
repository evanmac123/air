class UsersInRaffle < ActiveRecord::Base
  belongs_to :user
  belongs_to :raffle
end
