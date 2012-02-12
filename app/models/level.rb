class Level < ActiveRecord::Base
  include DemoScope

  belongs_to :demo
  has_and_belongs_to_many :users

  validates_presence_of :name
  validates_presence_of :threshold
  validates_presence_of :demo_id

  validates_uniqueness_of :threshold, :scope => :demo_id

  after_save :set_demo_level_indices
  after_create :schedule_retroactive_awards

  def level_up(user, channel)
    return nil if user.levels.include?(self)

    user.levels << self

    sms_text = I18n.translate(
      'activerecord.models.level.level_up_sms',
      :default    => "You've reached %{level_name}!",
      :level_name => self.name
    )

    OutgoingMessage.send_side_message(user, sms_text, :channel => channel)
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
    self.demo.users.where("points > ?", self.threshold).each {|user| self.level_up(user, nil)}
  end

  def set_demo_level_indices
    self.demo.set_level_indices
  end
end
