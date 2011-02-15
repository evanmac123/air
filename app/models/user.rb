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

  def self.claim_account(from, claim_code)
    return nil if User.find_by_phone_number(from)

    normalized_claim_code = claim_code.strip
    users = User.find(:all, :conditions => ["claim_code ILIKE ?", normalized_claim_code])

    if users.count > 1
      return "We found multiple people with your first initial and last name. Please try sending us your e-mail address instead."
    end

    user = users.first || User.find(:first, :conditions => ["email ILIKE ? AND claim_code != ''", normalized_claim_code])
    return nil unless user

    user.update_attributes(:phone_number => from, :claim_code => nil)
    "Welcome to the #{user.demo.company_name} game!"
  end

  def invite
    Mailer.invitation(self).deliver
    update_attribute(:invited, true)
  end

  def join_game(number)
    update_attribute(:phone_number, PhoneNumber.normalize(number))
    SMS.send(phone_number,
             "You've joined the #{demo.company_name} game! To play, send texts to this number. Send a text HELP if you want help.")
  end

  def gravatar_url(size)
    Gravatar.new(email).url(size)
  end

  def update_points(new_points)
    if new_points > 0
      increment!(:points, new_points)
    else
      decrement!(:points, new_points)
    end
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

    User.transaction do
      same_name = User.first(:conditions => ["slug LIKE ?", "#{cleaned}%"],
                             :order      => "created_at desc")

      self.slug = if same_name
                    counter = same_name.slug.first_digit + 1
                    "#{cleaned}-#{counter}"
                  else
                    cleaned
                  end
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

  private

  def claim_code_prefix
    names = name.split
    last_name = names.pop
    initials = names.map(&:first)
    (initials.join('') + last_name).remove_non_words.downcase
  end
end
