class Raffle < ActiveRecord::Base
  belongs_to :demo
  has_many :raffle_winners, dependent: :destroy#, foreign_key: :raffle_id
  has_many :winners, through: :raffle_winners, source: :user
  serialize :prizes, Array

  after_initialize :default_values

  #raffle statuses
  SET_UP = "set_up"
  LIVE = "live"
  PICK_WINNERS = "pick_winners"
  PICKED_WINNERS = "picked_winners"

  validates_presence_of :starts_at, :allow_blank => false, :message => "start date can't be blank"
  validates_presence_of :ends_at, :allow_blank => false, :message => "end date can't be blank"
  validates_presence_of :other_info, :allow_blank => false, :message => "other info can't be blank"
  validate :prizes_presence

  def update_attributes_without_validations raffle_params
    self.starts_at = raffle_params[:starts_at]
    self.ends_at = raffle_params[:ends_at]
    self.prizes = raffle_params[:prizes]
    self.other_info = raffle_params[:other_info]
    self.save(validate: false)
  end

  def pick_winners number, delete_old = winners
    participants = demo.users.with_some_tickets.order(:tickets)
    return nil if participants.empty?

    chances = []
    participants.each do |user|
      user.tickets.times {chances << user}
    end

    winners.delete(delete_old)
    number += winners.count

    begin
      index = rand(chances.length)
      winners.push chances[index] unless winners.include? chances[index]
    end while winners.count < number && winners.count < participants.count
    winners
  end

  def repick_winner old_winner
    pick_winners 1, old_winner
  end

  private
  def default_values
    self.prizes = [""] if prizes.empty?
    self.status = SET_UP unless status
    self.other_info = "For every 20 points you earn, you receive an entry into the prize raffle. " + \
    "We'll email the winner to award the prize within a week of the end of the prize period."
  end

  def prizes_presence
    if prizes.empty?
      errors.add(:prizes, "should have at least one prize") 
      default_values
    end
  end
end
