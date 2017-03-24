class TilesDigest < ActiveRecord::Base
  belongs_to :sender, class_name: 'User'
  belongs_to :demo

  validates_presence_of :demo
  # validates_presence_of :sender ##add after migrations

  has_one :follow_up_digest_email, dependent: :destroy
  has_many :tiles_digest_tiles
  has_many :tiles, through: :tiles_digest_tiles

  def self.dispatch(digest_params)
    digest = TilesDigest.new(digest_params)
    digest.set_tiles_and_update_cuttoff_time if digest.valid?

    digest.tap(&:save)
  end

  def deliver(follow_up_days_index)
    send_emails
    schedule_followup(follow_up_days_index)
    self.delivered
  end

  def send_emails
    TilesDigestMailer.delay.notify_all(
      demo,
      user_ids_to_deliver_to,
      tile_ids,
      headline,
      message,
      digest_subject,
      alt_subject
    )

    self.update_attributes(recipient_count: recipient_count_without_site_admin, delivered: true)
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

  private

    def users_for_digest
      if include_unclaimed_users
        demo.users
      else
        demo.claimed_users
      end
    end

    def recipient_count_without_site_admin
      users_to_deliver_to.where(is_site_admin: false).count
    end

    def users_to_deliver_to
      @users = users_for_digest
    end

    def user_ids_to_deliver_to
      @user_ids = users_to_deliver_to.pluck(:id)
    end

    def digest_subject
      subject || "New Tiles"
    end
end
