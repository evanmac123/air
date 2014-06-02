class Raffle < ActiveRecord::Base
  belongs_to :demo
  has_many :user_in_raffle_infos, dependent: :destroy
  has_many :blacklisted_users, through: :user_in_raffle_infos, source: :user, :conditions => "in_blacklist = true"
  has_many :winners, through: :user_in_raffle_infos, source: :user, :conditions => "is_winner = true"
  serialize :prizes, Array

  after_initialize :default_values
  before_destroy :remove_timer_to_end_live

  #raffle statuses
  SET_UP = "set_up".freeze
  LIVE = "live".freeze
  PICK_WINNERS = "pick_winners".freeze
  PICKED_WINNERS = "picked_winners".freeze

  validates_presence_of :starts_at, :allow_blank => false, :message => "start date can't be blank"
  validates_presence_of :ends_at, :allow_blank => false, :message => "end date can't be blank"
  validates_presence_of :other_info, :allow_blank => false, :message => "other info can't be blank"
  validate :prizes_presence

  def live?
    self.status == LIVE && self.starts_at <= Time.now
  end

  def finished?
    status == PICK_WINNERS || status == PICKED_WINNERS
  end

  def show_start? user
    user_in_raffle = find_user_in_raffle_info user
    if live? && !user_in_raffle.start_showed
      user_in_raffle.update_attributes(start_showed: true)
      true
    else
      false
    end
  end

  def show_finish? user
    user_in_raffle = find_user_in_raffle_info user
    if finished? && !user_in_raffle.finish_showed
      user_in_raffle.update_attributes(start_showed: true, finish_showed: true)
      true
    else
      false
    end
  end

  def update_attributes_without_validations raffle_params
    self.starts_at = raffle_params[:starts_at]
    self.ends_at = raffle_params[:ends_at]
    self.prizes = raffle_params[:prizes]
    self.other_info = raffle_params[:other_info]
    self.save(validate: false)
  end

  def pick_winners number, delete_old = winners
    add_blacklisted_users delete_old
    blacklist = blacklisted_users.empty? ? -1 : blacklisted_users.pluck(:id)
    participants = demo.users
                        .where('user_id not in (?)', blacklist)
                        .with_some_tickets.order(:tickets)
    return nil if participants.empty?

    chances = []
    participants.each do |user|
      user.tickets.times {chances << user}
    end

    delete_winners delete_old
    number += winners.count

    begin
      index = rand(chances.length)
      possible_winner = chances[index]

      if winners.include? possible_winner
        chances.delete(possible_winner)
        return nil if chances.empty?
      else
        add_winners possible_winner
      end
    end while winners.count < number
    winners
  end

  def repick_winner old_winner
    pick_winners 1, old_winner
  end

  def set_timer_to_end_live
    remove_timer_to_end_live
    self.delayed_job_id = ( self.delay(run_at: self.ends_at).finish_live ).id
    self.save(validate: false)
  end

  def remove_timer_to_end_live
    delayed_job = Delayed::Backend::ActiveRecord::Job.where(id: delayed_job_id).first
    delayed_job.destroy if delayed_job.present?
    true
  end

  def finish_live
    update_attribute(:status, PICK_WINNERS)
  end


  #
  # => UserInRaffleInfo methods
  #
  def find_user_in_raffle_info user
    UserInRaffleInfo.find_user_in_raffle_info self, user
  end

  def add_blacklisted_users users
    UserInRaffleInfo.add_blacklisted_users self, users
  end

  def add_winners users
    UserInRaffleInfo.add_winners self, users
  end

  def delete_winners users 
    UserInRaffleInfo.delete_winners self, users
  end

  private
  def default_values
    self.prizes = [""] if prizes.empty?
    self.status = SET_UP unless status
    unless other_info.present?
      self.other_info = "For every 20 points you earn, you receive an entry into the prize raffle. " + \
      "We'll email the winner to award the prize within a week of the end of the prize period."
    end
  end

  def prizes_presence
    if prizes.empty?
      errors.add(:prizes, "should have at least one prize") 
      default_values
    end
  end
end
