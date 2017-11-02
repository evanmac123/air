class Raffle < ActiveRecord::Base
  belongs_to :demo
  has_many :user_in_raffle_infos, dependent: :delete_all
  has_many :winners, through: :user_in_raffle_infos, source: :user, source_type: "User", :conditions => "is_winner = true"
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
  scope :live, ->(){where("status = ? and starts_at <= ?", LIVE, Time.current)}

  def live?
    self.status == LIVE && self.starts_at <= Time.current
  end

  def finished?
    status == PICK_WINNERS || status == PICKED_WINNERS
  end

  def show_start?(user)
    user_in_raffle = find_user_in_raffle_info(user)

    if live? && !user_in_raffle.start_showed
      user_in_raffle.update_attributes(start_showed: true)
    else
      return false
    end
  end

  def show_finish?(user)
    user_in_raffle = find_user_in_raffle_info user

    if finished? && !user_in_raffle.finish_showed && user_in_raffle.start_showed
      user_in_raffle.update_attributes(finish_showed: true)
    else
      return false
    end
  end

  def update_attributes_without_validations(raffle_params)
    self.starts_at = raffle_params[:starts_at]
    self.ends_at = raffle_params[:ends_at]
    self.prizes = raffle_params[:prizes]
    self.other_info = raffle_params[:other_info]
    self.save(validate: false)
  end

  def pick_winners(number_of_winners, repick = false)
    reset_winners unless repick
    participants = user_participants

    pool = create_entry_pool(participants)
    get_new_winners(number_of_winners, pool)
  end

  def repick_winner(old_winner)
    user_in_raffle_infos.where(user_id: old_winner.id).update_all(is_winner: false, in_blacklist: true)

    pick_winners(1, true).first
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

  private

    def get_new_winners(number_of_winners, pool, new_winners = [])
      number_of_winners.times do
        winner = pool.sample
        if winner
          add_winner(winner)
          new_winners << pool.delete(winner)
        end
      end

      new_winners
    end

    def blacklisted_user_ids
      user_in_raffle_infos.where(in_blacklist: true).pluck(:user_id)
    end

    def all_winners_selected?(number_of_winners, pool)
      winners.count == number_of_winners || pool.empty?
    end

    def create_entry_pool(participants)
      participants.inject([]) do |entries, user|
        user.tickets.times { entries << user }
        entries
      end
    end

    def user_participants
      demo.users.select([:id, :tickets, :name, :email]).where(User.arel_table[:id].not_in(blacklisted_user_ids)).with_some_tickets
    end

    def finish_live
      update_attribute(:status, PICK_WINNERS)
    end

    def reset_winners
      user_in_raffle_infos.where(is_winner: true).update_all(is_winner: false, in_blacklist: true)
    end

    def add_winner(winner)
      find_user_in_raffle_info(winner).update_attributes({ is_winner: true, in_blacklist: true })
    end

    def find_user_in_raffle_info(user)
      user_in_raffle_infos.where(user_id: user.id, user_type: user.class.name.to_s).first_or_create
    end

    def default_values
      self.prizes = [""] if prizes.empty?
      self.status = SET_UP unless status
      unless other_info.present?
        self.other_info = "We'll email the winner to award the prize within a week of the end of the prize period."
      end
    end

    def prizes_presence
      if prizes.empty?
        errors.add(:prizes, "should have at least one prize")
        default_values
      end
    end
end
