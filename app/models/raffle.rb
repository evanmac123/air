class Raffle < ActiveRecord::Base
  belongs_to :demo
  serialize :prizes, Array

  after_initialize :default_values

  #raffle statuses
  SET_UP = "set_up"
  LIVE = "live"
  PICK_WINNERS = "pick_winners"

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

  private
  def default_values
    self.prizes = [""] if prizes.empty?
    self.status = SET_UP unless status
  end

  def prizes_presence
    if prizes.empty?
      errors.add(:prizes, "should have at least one prize") 
      default_values
    end
  end
end
