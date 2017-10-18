class Act < ActiveRecord::Base
  include DemoScope
  extend ParsingMessage

  belongs_to :user, polymorphic: true
  belongs_to :referring_user, :class_name => "User"
  belongs_to :demo

  before_save do
    self.hidden = self.text.blank?

    # Privacy level is denormalized from user onto act in the interest of
    # making #allowed_to_view_by_privacy_settings more efficient. It was
    # killing our DB.
    self.privacy_level = user.privacy_level
    true
  end

  before_create do
    self.demo_id ||= user.demo.id
  end

  after_create do
    user.update_last_acted_at
    user.update_points(points, self.creation_channel) if points
  end

  scope :ordered, -> { order("created_at DESC") }

  attr_accessor :incoming_sms_sid, :suggestion_code

  def user_with_guest_allowed
    if user_id == 0
      GuestUser.new({demo_id: demo_id})
    else
      user_without_guest_allowed
    end
  end
  alias_method_chain :user, :guest_allowed

  def points
    self.inherent_points || 0
  end

  def post_act_summary
    user.point_and_ticket_summary
  end

  def self.unhidden
    where(:hidden => false)
  end

  def self.same_demo(user)
    where(:demo_id => user.demo_id)
  end

  def self.guest_user_acts
    where(user_type: GuestUser.to_s)
  end

  def self.user_acts
    where(user_type: User.to_s)
  end

  def self.displayable_to_user(viewing_user, board, page, per_page=5)
    if board.hide_social || viewing_user.is_a?(PotentialUser)
      return board.acts.ordered.where(user_id: viewing_user.id, user_type: User.to_s).page(page).per(per_page)
    end

    if viewing_user.is_client_admin || viewing_user.is_site_admin
      return board.acts.ordered.page(page).per(per_page)
    end

    if viewing_user.is_guest?
      return board.acts.guest_user_acts.where(user_id: viewing_user.id, user_type: GuestUser.to_s).ordered.page(page).per(per_page)
    end

    friends = viewing_user.displayable_accepted_friends
    viewable_user_ids = friends.pluck(:id) + [viewing_user.id]

    board.acts.user_acts.unhidden.where("(user_id in (?) or privacy_level='everybody')", viewable_user_ids).ordered.page(page).per(per_page)
  end

  def self.for_profile(viewing_user)
    displayable_to_user(viewing_user, viewing_user.demo, 1, 10)
  end

  protected

  def data_for_mixpanel
    {
      :time                  => Time.now,
      :tagged_user_id        => self.referring_user_id,
      :channel               => self.creation_channel,
      :suggestion_code       => self.suggestion_code
    }
  end

  def self.extract_user_and_phone(user_or_phone)
    if user_or_phone.kind_of?(User)
      user = user_or_phone
      phone_number = user.phone_number
    else
      user = User.find_by_phone_number(user_or_phone)
      phone_number = user_or_phone
    end

    [user, phone_number]
  end

  def self.done_today
    where("created_at BETWEEN ? AND ?", Date.today.midnight, Date.tomorrow.midnight)
  end
end
