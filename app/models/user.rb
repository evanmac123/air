require 'digest/sha1'

class User < ActiveRecord::Base
  # Maximum number of days back we will consider acts in the moving average
  # (counting today as day 0)
  MAX_RECENT_AVERAGE_HISTORY_DEPTH = 6

  include Clearance::User

  belongs_to :demo
  has_many   :acts
  has_many   :friendships
  has_many   :friends, :through => :friendships

  before_create do
    set_invitation_code
    set_slugs
    set_alltime_rankings
    set_recent_average_rankings
  end

  before_update do
    set_alltime_rankings if changed.include?('points')
    set_recent_average_rankings if (!batch_updating_recent_averages && changed.include?('recent_average_points'))
  end

  before_save do
    downcase_email
  end

  validates_uniqueness_of :slug

  attr_reader :batch_updating_recent_averages

  def followers
    # You'd think you could do this with an association, and if you can figure
    # out how to get that to work, please, be my guest.

    self.class.joins("INNER JOIN friendships on users.id = friendships.user_id").where('friendships.friend_id = ?', self.id)
  end

  def to_param
    slug
  end

  def self.alphabetical
    order("name asc")
  end

  def self.top(limit)
    order("points desc").limit(limit)
  end

  def self.ranked
    where("phone_number IS NOT NULL AND phone_number != ''")
  end

  def self.claim_account(from, claim_code)
    normalized_claim_code = claim_code.gsub(/\W+/, '')
    users = User.find(:all, :conditions => ["claim_code ILIKE ?", normalized_claim_code])

    if users.count > 1
      return "We found multiple people with your first initial and last name. Please try sending us your e-mail address instead."
    end

    user = users.first 
    unless user
      normalized_email = claim_code.gsub(/\s+/, '')
      user = User.find(:first, :conditions => ["email ILIKE ? AND claim_code != ''", normalized_email])
    end

    return nil unless user

    if (existing_user = User.find_by_phone_number(from))
      return "You've already claimed your account, and currently have #{existing_user.points} points."
    end

    new_password = claim_code_prefix(user)
    user.update_attributes(
      :phone_number          => from, 
      :password              => new_password,
      :password_confirmation => new_password
    )

    add_joining_to_activity_stream(user)
    user.demo.welcome_message(user)
  end

  def invite
    Mailer.invitation(self).deliver
    update_attribute(:invited, true)
  end

  def join_game(number)
    update_attribute(:phone_number, PhoneNumber.normalize(number))
    add_joining_to_activity_stream
    SMS.send(phone_number, demo.welcome_message(self))
  end

  def gravatar_url(size)
    Gravatar.new(email).url(size)
  end

  def update_points(new_points)
    increment!(:points, new_points)
    update_recent_average_points(new_points)
    check_for_victory
  end

  def update_recent_average_points(new_points)
    point_gain_factor = (recent_average_history_depth + 1).to_f / (1..(recent_average_history_depth + 1)).sum.to_f
    actual_point_gain = (new_points * point_gain_factor).ceil
    increment!(:recent_average_points, actual_point_gain)
  end

  def password_optional?
    true
  end

  def set_invitation_code
    self.invitation_code = Digest::SHA1.hexdigest("--#{Time.now.utc}--#{email}--")
  end

  def set_slugs
    cleaned = name.remove_mid_word_characters.
                replace_non_words_with_spaces.
                strip.
                replace_spaces_with_hyphens
    possible_slug = cleaned
    possible_sms_slug = self.claim_code_prefix

    User.transaction do
      same_name = find_same_slug(possible_slug, possible_sms_slug)
      counter = same_name && same_name.slug.first_digit

      while same_name
        counter += rand(20)
        possible_slug = "#{cleaned}-#{counter}"
        possible_sms_slug = self.claim_code_prefix + counter.to_s
        same_name = find_same_slug(possible_slug, possible_sms_slug)
      end

      self.slug = possible_slug
      self.sms_slug = possible_sms_slug
    end
  end

  def following?(other)
    friends.include?(other)
  end

  def followers_count
    Friendship.where(:friend_id => id).count
  end

  def following_count
    Friendship.where(:user_id => id).count
  end

  def generate_simple_claim_code!
    update_attributes(:claim_code => claim_code_prefix)
  end

  def generate_unique_claim_code!
    potential_claim_code = nil

    User.transaction do
      suffix = rand(100)

      begin
        suffix += rand(50)
        potential_claim_code = claim_code_prefix + suffix.to_s
      end while User.find_by_claim_code(potential_claim_code)

      self.update_attributes(:claim_code => potential_claim_code)
    end

    potential_claim_code
  end

  def set_ranking(points_column, ranking_column)
    User.transaction do
      new_point_value = self[points_column]

      self[ranking_column] = self.demo.users.where("#{points_column} > ?", new_point_value).count + 1
      old_point_value = self.changed_attributes[points_column]

      # Remember, we haven't saved the new point value yet, so if self isn't a
      # new record (hence already has a database ID), we need to specifically
      # exempt it from this update.

      if self.id
        where_conditions = ["#{points_column} < ? AND #{points_column} >= ? AND id != ?", new_point_value, old_point_value, self.id]
      else
        where_conditions = ["#{points_column} < ? AND #{points_column} >= ?", new_point_value, old_point_value]
      end

      self.demo.users.update_all("#{ranking_column} = #{ranking_column} + 1", where_conditions)
    end
  end

  def set_alltime_rankings
    set_ranking('points', 'ranking')
  end

  def set_recent_average_rankings
    set_ranking('recent_average_points', 'recent_average_ranking')
  end

  def point_and_ranking_summary
    result = if (victory_threshold = self.demo.victory_threshold)
      "Points #{self.points}/#{victory_threshold}, r"
    else
      "R"
    end

    result += "ank #{self.ranking}/#{self.demo.users.ranked.count}."

    result
  end

  def claim_code_prefix
    self.class.claim_code_prefix(self)
  end

  # This is meant to be called by a cron job just after midnight, to
  # recalculate this user's moving average score. Note that this does _not_
  # update the user's ranking, since it's expected that this will be called on
  # a whole batch of users at once, and it'll be more efficient to recalculate
  # all rankings at once afterwards.
  
  def recalculate_moving_average!
    horizon = (Date.today - MAX_RECENT_AVERAGE_HISTORY_DEPTH.days).midnight
    acts_in_horizon = acts.where('created_at >= ? AND demo_id = ?', horizon, self.demo_id).order(:created_at)
    oldest_act_in_horizon = acts_in_horizon.first

    self.recent_average_history_depth = if oldest_act_in_horizon
                             # Date#- returns not an integer, but a Rational, 
                             # for doubtless the best of reasons.
                             (Date.today - oldest_act_in_horizon.created_at.to_date).numerator
                           else
                             0
                           end

    grouped_acts = acts_in_horizon.group_by{|act| act.created_at.to_date}

    point_numerator = 0
    grouped_acts.each do |date_of_act, acts_on_date|
      date_weight = self.recent_average_history_depth - (Date.today - date_of_act).numerator + 1
      point_numerator += date_weight * acts_on_date.map(&:points).compact.sum
    end

    point_denominator = (1..self.recent_average_history_depth + 1).sum
    self.recent_average_points = (point_numerator.to_f / point_denominator).ceil

    # Remember we're deliberately skipping callbacks here because we
    # anticipate updating rankings all in a batch.
    @batch_updating_recent_averages = true
    self.save
    @batch_updating_recent_averages = false
  end

  def self.claim_code_prefix(user)
    begin
      names = user.name.downcase.split.map(&:remove_non_words)
      first_name = names.first
      last_name = names.last
      [first_name.first, last_name].join('')
    rescue StandardError => e
      Rails.logger.error("ERROR IN .CLAIM_CODE_PREFIX")
      Rails.logger.error("FULL NAME: #{names.inspect}")
      Rails.logger.error("FIRST NAME: #{first_name}")
      Rails.logger.error("LAST NAME: #{last_name}")
      raise e
    end
  end

  def move_to_new_demo(new_demo_id)
    new_demo = Demo.find(new_demo_id)
    self.demo = new_demo
    self.points = self.acts.where(:demo_id => new_demo_id).map(&:points).sum
    self.save!
    self.recalculate_moving_average!

    new_demo.fix_total_user_rankings!
    new_demo.fix_recent_average_user_rankings!
  end

  protected

  def downcase_email
    self.email = email.to_s.downcase
  end

  private

  def self.add_joining_to_activity_stream(user)
    Act.create!(
      :user            => user,
      :text            => 'joined the game',
      :inherent_points => user.demo.seed_points
    )
  end

  def add_joining_to_activity_stream
    self.class.add_joining_to_activity_stream(self)
  end

  def check_for_victory
    return unless (victory_threshold = self.demo.victory_threshold)

    if !self.won_at && self.points >= victory_threshold
      self.won_at = Time.now
      self.save!

      send_victory_notices
    end
  end

  def send_victory_notices
    SMS.send(
      self.phone_number,
      "Congratulations! You've scored #{self.points} points and won the game!"
    )

    SMS.send(
      self.demo.victory_verification_sms_number,
      "#{self.name} (#{self.email}) won with #{self.points} points"
    ) if self.demo.victory_verification_sms_number

    Mailer.victory(self).deliver if self.demo.victory_verification_email
  end

  def find_same_slug(possible_slug, possible_sms_slug)
    User.first(:conditions => ["slug = ? OR sms_slug = ?", possible_slug, possible_sms_slug],
               :order      => "created_at desc")
  end
end
