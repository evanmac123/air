class RaffleWinner < ActiveRecord::Base
  belongs_to :raffle
  belongs_to :user
end
