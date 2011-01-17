require 'digest/sha1'

class User < ActiveRecord::Base
  include Clearance::User

  belongs_to :demo

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
