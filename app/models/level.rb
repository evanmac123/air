class Level < ActiveRecord::Base
  belongs_to :demo
  has_and_belongs_to_many :users

  validates_presence_of :name
  validates_presence_of :threshold
  validates_presence_of :demo_id

  validates_uniqueness_of :threshold, :scope => :demo_id

  def level_up(user)
    user.levels << self

    sms_text = I18n.translate(
      'activerecord.models.level.level_up_sms',
      :default    => "You've reached %{level_name}!",
      :level_name => self.name
    )

    SMS.send(
      user.phone_number,
      sms_text
    )
  end

  def self.check_for_level_up(old_points, user)
    user.demo.levels.crossed(old_points, user.points).in_threshold_order.all.each{|level| level.level_up(user)}
  end

  def self.crossed(old_points, new_points)
    where(["threshold BETWEEN ? AND ?", old_points + 1, new_points])
  end

  def self.in_threshold_order
    order("threshold ASC")
  end
end
