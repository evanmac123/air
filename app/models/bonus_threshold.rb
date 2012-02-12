class BonusThreshold < ActiveRecord::Base
  belongs_to :demo
  has_and_belongs_to_many :users

  validates_presence_of :min_points, :max_points, :award, :demo_id

  validate :max_points_gte_min_points
  validate :no_overlap

  def max_points_gte_min_points
    return unless min_points && max_points

    if self.min_points > self.max_points
      self.errors.add(:min_points, "Max points must be greater than or equal to min points")
    end
  end

  def no_overlap
    {:min_points => min_points, :max_points => max_points}.each do |field_name, points|
      overlapped = self.class.where(['? BETWEEN min_points AND max_points', points]).where(:demo_id => self.demo_id)
      unless self.new_record?
        overlapped = overlapped.where(['id != ?', self.id])
      end

      if conflicting = overlapped.first
        self.errors.add(field_name, "of #{points} would overlap with another threshold (#{conflicting.min_points}-#{conflicting.max_points})")
      end
    end
  end

  # Decide whether or not to award points to a user depending on how deep 
  # into (or past) the spread their score is.
  #
  # They have a m/n chance of winning the points (capped at 1), where 
  # m = their score - min points + 1, and
  # n = max points - min points + 1

  def award_points?(user)
    return false if user.bonus_thresholds.include?(self)

    score = user.points
    return false if score < min_points
    return true if score >= max_points

    probabilistically_award_points?(score)
  end

  def self.consider_awarding_points_for_crossed_bonus_thresholds(old_points, user, channel)
    crossed_bonus_thresholds = user.demo.bonus_thresholds.
                                 crossed(old_points, user.points).
                                 select{|crossed_bonus_threshold| crossed_bonus_threshold.award_points?(user)}

    crossed_bonus_thresholds.each do |crossed_bonus_threshold|
      act_text = I18n.translate(
        'activerecord.models.user.crossed_bonus_threshold_act', 
        :default => "got %{award} bonus points for passing a bonus threshold", 
        :award   => crossed_bonus_threshold.award
      )

      sms_text = I18n.translate(
        'activerecord.models.user.crossed_bonus_threshold_sms', 
        :default => "You got %{award} bonus points for passing a bonus threshold! Nice going!",
        :award   => crossed_bonus_threshold.award
      )

      user.bonus_thresholds << crossed_bonus_threshold

      user.acts.create(
        :text            => act_text,
        :inherent_points => crossed_bonus_threshold.award
      )

      OutgoingMessage.send_side_message(user, sms_text, :channel => channel)
    end  
  end

  def self.crossed(old_score, new_score)
    where(['(? BETWEEN min_points AND max_points) OR (min_points > ? AND max_points < ?)', new_score, old_score, new_score])
  end

  def self.in_threshold_order
    order('min_points ASC')
  end

  protected

  def probabilistically_award_points?(score)
    spread = max_points - min_points + 1
    random_number = rand(spread) + 1
    return (score - min_points + 1) >= random_number
  end
end
