class Raffle < ActiveRecord::Base
  belongs_to :demo
  serialize :prizes, Array
end
