class Level < ActiveRecord::Base
  include DemoScope

  belongs_to :demo
  has_and_belongs_to_many :users

  validates_presence_of :name
  validates_presence_of :threshold
  validates_presence_of :demo_id

  validates_uniqueness_of :threshold, :scope => :demo_id

  after_save :set_demo_level_indices
  after_destroy :set_demo_level_indices
  after_create :schedule_retroactive_awards

  CHANNELS_THAT_GET_LEVEL_UP_MESSAGES = %w(web sms)

  def level_up(user, channel)
    return nil if user.levels.include?(self)

    user.levels << self

    OutgoingMessage.send_side_message(user, self.name, :channel => channel) if channel_gets_level_up_messages?(channel)
  end

  def self.check_for_level_up(old_points, user, channel)
    user.demo.levels.crossed(old_points, user.points).in_threshold_order.all.each{|level| level.level_up(user, channel)}
  end

  def self.crossed(old_points, new_points)
    where(["threshold BETWEEN ? AND ?", old_points + 1, new_points])
  end

  def self.in_threshold_order
    order("threshold ASC")
  end

  protected

  def schedule_retroactive_awards
    self.delay.award_retroactively
  end

  def award_retroactively
    self.demo.users.where("points > ?", self.threshold).each {|user| self.level_up(user, :none)}
  end

  def set_demo_level_indices
    self.demo.set_level_indices
  end

  def channel_gets_level_up_messages?(channel)
    CHANNELS_THAT_GET_LEVEL_UP_MESSAGES.include?(channel.to_s)
  end
end
