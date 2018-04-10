# frozen_string_literal: true

class TilesDigest < ActiveRecord::Base
  DEFAULT_DIGEST_SUBJECT = "New Tiles"

  include TilesDigestConcern

  belongs_to :sender, class_name: "User"
  belongs_to :demo

  validates_presence_of :demo

  has_one :follow_up_digest_email, dependent: :destroy
  has_many :tiles_digest_tiles
  has_many :tiles, through: :tiles_digest_tiles

  before_save :set_default_subject
  before_save :sanitize_subject_lines

  after_destroy :destroy_from_redis

  def destroy_from_redis
    self.redis.delete_all
  end

  def self.paid
    joins(:demo).where(demos: { customer_status_cd: Demo.customer_statuses[:paid] })
  end

  def self.smb
    joins(demo: :organization).where(organizations: { company_size_cd: Organization.company_sizes[:smb] })
  end

  def self.enterprise
    joins(demo: :organization).where(organizations: { company_size_cd: Organization.company_sizes[:enterprise] })
  end

  def self.dispatch(digest_params)
    digest = TilesDigest.new(digest_params)
    if digest.valid?
      digest.set_tiles
    end

    digest.tap(&:save)
  end

  def set_tiles
    self.tiles << demo.digest_tiles
  end

  def deliver(follow_up_days_index)
    demo.clear_tile_email_draft
    send_emails_and_sms
    schedule_followup(follow_up_days_index)
    set_tile_email_report_notifications
    self.delivered
  end

  def set_tile_email_report_notifications
    ClientAdmin::NotificationsManager.delay(run_at: 1.hour.from_now).set_tile_email_report_notifications(board: self.demo)
  end

  def send_emails_and_sms
    self.assign_attributes(sent_at: Time.current, delivered: true)
    self.update_attributes(recipient_count: recipient_count_without_site_admin)

    TilesBulkActivator.call(demo: demo, tiles: tiles)
    TilesDigestBulkMailJob.perform_later(self)
  end

  def all_related_subject_lines
    [
      subject,
      alt_subject,
      follow_up_digest_email.try(:subject)
    ].compact
  end

  def highest_performing_subject_line
    unique_logins_by_subject_line[1] || subject
  end

  def new_unique_login?(user_id:)
    self.redis[:unique_login_set].call(:sadd, user_id) == 1
  end

  def increment_unique_logins_by_subject_line(subject_line)
    self.redis[:unique_logins].call(:zincrby, 1, subject_line)
  end

  def unique_logins_by_subject_line
    self.redis[:unique_logins].call(:zrangebyscore, "-inf", "inf", "WITHSCORES").reverse
  end

  def increment_logins_by_subject_line(subject_line)
    self.redis[:logins].call(:zincrby, 1, subject_line)
  end

  def increment_sms_logins
    self.redis[:sms_logins].call(:incr)
  end

  def logins_by_subject_line
    self.redis[:logins].call(:zrangebyscore, "-inf", "inf", "WITHSCORES").reverse
  end

  def schedule_followup(follow_up_days_index)
    if follow_up_days_index != 0 && delivered == true
      self.create_follow_up_digest_email(
        send_on:  Date.current + follow_up_days_index.days
      )
    end
  end

  def tile_ids
    tiles.pluck(:id)
  end

  def tile_ids_for_user(user)
    tiles.segmented_for_user(user).pluck(:id)
  end

  def users
    include_unclaimed_users ? users_for_digest : claimed_users_for_digest
  end

  def user_ids_to_deliver_to
    users.pluck(:id)
  end

  def sender_name
    sender.try(:name)
  end

  ### Reporting Concern

  def self.tile_completion_report
    data = all.map(&:tile_completion_rate)
    data_without_outliers = AirboStatistics.new(data: data).dataset_without_outliers

    data_without_outliers
  end

  def self.tile_view_report
    data = all.map(&:tile_view_rate)
    data_without_outliers = AirboStatistics.new(data: data).dataset_without_outliers

    data_without_outliers
  end

  def self.active_user_report
    data = all.map(&:active_user_rate)
    data_without_outliers = AirboStatistics.new(data: data).dataset_without_outliers

    data_without_outliers
  end

  def eligible_tile_action_count
    recipient_count.to_i * tiles.count.to_f
  end

  def tile_completion_rate
    if eligible_tile_action_count > 0
      tile_completions_from_recipients.where(tile_completions: { created_at: sent_at..reporting_cutoff_for_tile_action }).count / eligible_tile_action_count
    end
  end

  def tile_view_rate
    if eligible_tile_action_count > 0
      tile_viewings_from_recipients.where(tile_viewings: { created_at: sent_at..reporting_cutoff_for_tile_action }).count / eligible_tile_action_count
    end
  end

  def active_user_rate
    if recipient_count.to_i > 0
      tile_completions_from_recipients.where(tile_completions: { created_at: sent_at..reporting_cutoff_for_tile_action }).pluck(:user_id).uniq.count / recipient_count.to_f
    end
  end

  def tile_completions_from_recipients
    tiles.joins(:tile_completions).where(tile_completions: { user_id: users.pluck(:id) })
  end

  def tile_viewings_from_recipients
    tiles.joins(:tile_viewings).where(tile_viewings: { user_id: users.pluck(:id) })
  end

  def reporting_cutoff_for_tile_action
    if follow_up_digest_email.present?
      (follow_up_digest_email.send_on + reporting_buffer_period).end_of_day
    else
      (sent_at + reporting_buffer_period).end_of_day
    end
  end

  def reporting_buffer_period
    5.days
  end

  def resolve_subject(idx)
    return subject unless alt_subject
    idx.even? ? alt_subject : subject
  end

  ###

  private

    def users_for_digest
      demo.users.where("board_memberships.notification_pref_cd != ?", BoardMembership.unsubscribe).where("board_memberships.created_at <= ?", sent_at)
    end

    def claimed_users_for_digest
      users_for_digest.where("board_memberships.joined_board_at IS NOT NULL AND board_memberships.joined_board_at <= ?", sent_at)
    end

    def recipient_count_without_site_admin
      users.where(is_site_admin: false).count
    end

    def sanitize_subject_lines
      self.subject = sanitize_subject_line(subject)
      self.alt_subject = sanitize_subject_line(alt_subject)
    end

    def set_default_subject
      if subject.blank?
        self.subject = DEFAULT_DIGEST_SUBJECT
      end
    end
end
