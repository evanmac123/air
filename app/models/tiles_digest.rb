class TilesDigest < ActiveRecord::Base
  DEFAULT_DIGEST_SUBJECT = "New Tiles"

  include TilesDigestConcern
  belongs_to :sender, class_name: 'User'
  belongs_to :demo

  validates_presence_of :demo
  # validates_presence_of :sender ##add after migrations

  has_one :follow_up_digest_email, dependent: :destroy
  has_many :tiles_digest_tiles
  has_many :tiles, through: :tiles_digest_tiles

  before_save :set_default_subject
  before_save :sanitize_subject_lines

  after_destroy :destroy_from_redis

  def destroy_from_redis
    rdb.destroy
  end

  def self.dispatch(digest_params)
    digest = TilesDigest.new(digest_params)
    digest.set_tiles_and_update_cuttoff_time if digest.valid?

    digest.tap(&:save)
  end

  def deliver(follow_up_days_index)
    send_emails
    schedule_followup(follow_up_days_index)
    set_tile_email_report_notifications
    self.delivered
  end

  def set_tile_email_report_notifications
    ClientAdmin::NotificationsManager.delay.set_tile_email_report_notifications(board: self.demo)
  end

  def send_emails
    TilesDigestMailer.delay.notify_all(self)

    self.update_attributes(recipient_count: recipient_count_without_site_admin, delivered: true)
  end

  def all_related_subject_lines
    [subject, alt_subject, follow_up_digest_email_subject].compact
  end

  def follow_up_digest_email_subject
    follow_up_digest_email.decorated_subject if follow_up_digest_email
  end

  def new_unique_login?(user_id:)
    rdb[:unique_login_set].sadd(user_id) == 1
  end

  def increment_unique_logins_by_subject_line(subject_line)
    rdb[:unique_logins].zincrby(1, subject_line)
  end

  def unique_logins_by_subject_line
    rdb[:unique_logins].zrangebyscore("-inf", "inf", "WITHSCORES").reverse
  end

  def increment_logins_by_subject_line(subject_line)
    rdb[:logins].zincrby(1, subject_line)
  end

  def logins_by_subject_line
    rdb[:logins].zrangebyscore("-inf", "inf", "WITHSCORES").reverse
  end

  def schedule_followup(follow_up_days_index)
    if follow_up_days_index != 0 && delivered == true
      self.create_follow_up_digest_email(
        send_on:  Date.today + follow_up_days_index.days,
        user_ids_to_deliver_to: user_ids_to_deliver_to,
      )
    end
  end

  def tile_ids
    tiles.pluck(:id)
  end

  def tiles_for_email
    tiles.active
  end

  def tile_ids_for_email
    tiles_for_email.pluck(:id)
  end

  def users
    if include_unclaimed_users
      users_for_digest.where("users.created_at < ?", self.created_at)
    else
      users_for_digest.where("users.accepted_invitation_at < ?", self.created_at)
    end
  end

  def set_tiles_and_update_cuttoff_time
    self.cutoff_time = demo.tile_digest_email_sent_at
    set_tiles
  end

  def set_tiles
    demo.digest_tiles(cutoff_time).each do |tile|
      self.tiles << tile
    end
  end

  def user_ids_to_deliver_to
    @user_ids = users_to_deliver_to.pluck(:id)
  end

  def sender_name
    sender.try(:name)
  end

  private

    def users_for_digest
      if include_unclaimed_users
        demo.users_for_digest
      else
        demo.claimed_users_for_digest
      end
    end

    def recipient_count_without_site_admin
      users_to_deliver_to.where(is_site_admin: false).count
    end

    def users_to_deliver_to
      @users = users_for_digest
    end

    def sanitize_subject_lines
      self.subject = sanitize_subject_line(subject)
      self.alt_subject = sanitize_subject_line(alt_subject)
    end

    def set_default_subject
      if subject.nil?
        self.subject = DEFAULT_DIGEST_SUBJECT
      end
    end
end
