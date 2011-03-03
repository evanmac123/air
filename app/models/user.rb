require 'digest/sha1'

class User < ActiveRecord::Base
  include Clearance::User

  belongs_to :demo
  has_many   :acts
  has_many   :friendships
  has_many   :friends, :through => :friendships, :foreign_key => :friend_id

  before_create do
    set_invitation_code
    set_slug
    set_rankings
  end

  before_update do
    set_rankings if changed.include?('points')
  end

  before_save do
    downcase_email
  end

  validates_uniqueness_of :slug

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
    normalized_claim_code = claim_code.strip
    users = User.find(:all, :conditions => ["claim_code ILIKE ?", normalized_claim_code])

    if users.count > 1
      return "We found multiple people with your first initial and last name. Please try sending us your e-mail address instead."
    end

    user = users.first || User.find(:first, :conditions => ["email ILIKE ? AND claim_code != ''", normalized_claim_code])
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

    user.get_seed_points
    add_joining_to_activity_stream(user)
    user.demo.welcome_message
  end

  def invite
    Mailer.invitation(self).deliver
    update_attribute(:invited, true)
  end

  def join_game(number)
    update_attribute(:phone_number, PhoneNumber.normalize(number))
    get_seed_points
    add_joining_to_activity_stream
    SMS.send(phone_number, demo.welcome_message)
  end

  def gravatar_url(size)
    Gravatar.new(email).url(size)
  end

  def update_points(new_points)
    increment!(:points, new_points)
    check_for_victory
  end

  def password_optional?
    true
  end

  def set_invitation_code
    self.invitation_code = Digest::SHA1.hexdigest("--#{Time.now.utc}--#{email}--")
  end

  def set_slug
    cleaned = name.remove_mid_word_characters.
                replace_non_words_with_spaces.
                strip.
                replace_spaces_with_hyphens
    possible_slug = cleaned

    User.transaction do
      same_name = find_same_name(possible_slug)
      counter = same_name && same_name.slug.first_digit

      while same_name
        counter += rand(20)
        possible_slug = "#{cleaned}-#{counter}"
        same_name = find_same_name(possible_slug)
      end

      self.slug = possible_slug
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

  def set_rankings
    User.transaction do
      self.ranking = self.demo.users.where('points > ?', points).count + 1
      old_point_value = self.changed_attributes['points']
      new_point_value = self.points

      # Remember, we haven't saved the new point value yet, so if self isn't a
      # new record (hence already has a database ID), we need to specifically
      # exempt it from this update.

      if self.id
        where_conditions = ['points < ? AND points >= ? AND id != ?', new_point_value, old_point_value, self.id]
      else
        where_conditions = ['points < ? AND points >= ?', new_point_value, old_point_value]
      end

      self.demo.users.update_all('ranking = ranking + 1', where_conditions)
    end
  end

  def get_seed_points
    if demo.seed_points > 0
      update_points(demo.seed_points)
    end
  end

  protected

  def downcase_email
    self.email = email.to_s.downcase
  end

  private

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

  def self.add_joining_to_activity_stream(user)
    Act.create!(
      :user => user,
      :text => 'joined the game'
    )
  end

  def claim_code_prefix
    self.class.claim_code_prefix(self)
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

  def find_same_name(cleaned)
    User.first(:conditions => ["slug LIKE ?", "#{cleaned}%"],
               :order      => "created_at desc")
  end
end
