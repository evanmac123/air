# frozen_string_literal: true

class Organization < ActiveRecord::Base
  resourcify
  include NormalizeBlankValues

  before_save :update_slug
  before_save :normalize_blank_values

  has_many :subscriptions, dependent: :destroy
  has_many :invoices, through: :subscriptions
  has_many :invoice_transactions, through: :invoices

  has_many :demos, autosave: true, dependent: :destroy
  has_many :campaigns, through: :demos
  has_many :lead_contacts, dependent: :destroy
  has_many :boards, class_name: :Demo, autosave: true
  has_many :tiles, through: :boards
  has_many :board_memberships, through: :boards
  has_many :users

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validate  :free_trial_cannot_start_before_created_at_or_in_future

  scope :name_order, -> { order(:name) }

  has_attached_file :logo,
    styles: { small: "x40>", medium: "x120>" },
    default_style: :small
  validates_attachment_content_type :logo, content_type: /\Aimage\/.*\Z/

  as_enum :company_size, smb: 0, enterprise: 1

  def self.smb
    where(company_size_cd: Organization.company_sizes[:smb])
  end

  def self.enterprise
    where(company_size_cd: Organization.company_sizes[:enterprise])
  end

  def self.paid
    joins(:demos).where(demos: { customer_status_cd: Demo.customer_statuses[:paid] }).uniq
  end

  def self.paid_at_date(date:)
    Organization.joins(:subscriptions).where("subscriptions.subscription_start <= ?", date).where("subscriptions.cancelled_at IS NULL OR cancelled_at > ?", date).uniq
  end

  def self.paid_organizations_count
    paid.count
  end

  def free_trial_cannot_start_before_created_at_or_in_future
    if free_trial_started_at.present? && (free_trial_started_at < created_at.to_date || free_trial_started_at > Date.current)
      errors.add(:free_trial_started_at, "can't be before #{created_at} or in the future")
    end
  end

  def role_names
    roles.pluck(:name)
  end

  def self.id_and_name
    select([:id, :name])
  end

  def update_slug
    self.slug = name.parameterize
  end

  def to_param
    self.slug
  end

  def is_in_sales?
    roles.pluck(:name).include?("sales")
  end

  def user_activation_rate
    user_count = users.count
    if user_count.nonzero?
      (activated_users.count.to_f / user_count) * 100
    else
      0
    end
  end

  def activated_users
    arel_users = User.arel_table
    users.non_site_admin.where(arel_users[:accepted_invitation_at].not_eq(nil))
  end

  def customer_status
    if paid?
      :paid
    elsif trial?
      :trial
    else
      :free
    end
  end

  def paid?
    demos.where(demos: { customer_status_cd: Demo.customer_statuses[:paid] }).count > 0
  end

  def trial?
    demos.where(demos: { customer_status_cd: Demo.customer_statuses[:trial] }).count > 0
  end

  def free?
    !paid?
  end
end
