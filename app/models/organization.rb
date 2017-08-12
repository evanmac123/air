class Organization < ActiveRecord::Base
  resourcify
  acts_as_taggable_on :channels
  include NormalizeBlankValues

  before_save :update_slug
  before_save :normalize_blank_values

  has_many :contracts
  has_many :subscriptions, dependent: :destroy
  has_many :invoices, through: :subscriptions
  has_many :invoice_transactions, through: :invoices

  has_many :demos, autosave: true, dependent: :destroy
  has_many :lead_contacts, dependent: :destroy
  has_many :boards, class_name: :Demo, autosave: true
  has_many :tiles, through: :boards
  has_many :board_memberships, through: :boards
  has_many :users
  has_one :onboarding, autosave: true

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validate :free_trial_cannot_start_before_created_at_or_in_future

  accepts_nested_attributes_for :boards
  accepts_nested_attributes_for :users

  scope :name_order, -> { order(:name) }
  scope :featured, -> { where(featured: true) }

  has_attached_file :logo,
    {
      styles: { small: "x40>", medium: "x120>" },
      default_style: :small
    }

  def self.paid_organizations_count
    joins(:demos).where(demos: { is_paid: true }).uniq.count
  end

  def free_trial_cannot_start_before_created_at_or_in_future
    if free_trial_started_at.present? && (free_trial_started_at < created_at.to_date || free_trial_started_at.to_time > Time.now)
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

  def track_channels(channels)
    channel_list.add(channels)
    self.save
  end

  def self.as_customer
    joins(:contracts).uniq
  end

  def self.active_as_of_date d
    as_customer.select{|o| o.active_as_of_date(d)}
  end

  def self.currently_active
    active_as_of_date(Date.today)
  end

  def self.active_during_period sdate, edate
    as_customer.select{|o| o.active_during_period(sdate, edate)}
  end

  def self.added_during_period sdate, edate
    as_customer.select{|o| o.added_during_period(sdate, edate)}
  end

  def self.churned_during_period sdate, edate
    possible_churn_during_period(sdate, edate).select{|o|o.contracts.auto_renewing.count == 0}
  end

  def self.with_deliquent_contracts_as_of_date date
    as_customer.select{|o|o.contracts.delinquent_as_of(date).count > 0}
  end

  def self.delinquent_as_of_date date
    with_deliquent_contracts_as_of_date(date).select{|o|o.contracts.active_as_of_date(date).count == 0}
  end

  def self.possible_churn_during_period sdate, edate
    active_as_of_date(sdate).select{|o| o.contracts.active_not_expiring_during_period(sdate,edate).count == 0 }
  end

  def mrr_churn_during_period sdate, edate
    current = mrr_as_of_date(edate)
    starting = mrr_as_of_date(sdate)
    current-starting
  end

  def mrr_as_of_date date
    active_contracts_as_of_date(date).sum(&:calc_mrr)
  end

  def active_contracts_as_of_date date
    contracts.active_as_of_date(date)
  end

  def added_during_period sdate, edate
    has_start_and_end && customer_start_date >= sdate && customer_start_date <= edate
  end

  def active_during_period sdate, edate
    has_start_and_end && customer_start_date <= edate  && customer_end_date >= edate
  end

  def active_as_of_date date
    contracts.active_as_of_date(date).count > 0
  end

  def active_mrr
    contracts.active.sum(&:calc_mrr)
  end


  def mrr_during_period sdate, edate
    contracts.mrr_during_period(sdate, edate)
  end

  def customer_start_date
    @cust_start ||= contracts.order(:start_date).first.try(:start_date)
  end

  def customer_end_date
    @cust_end ||= contracts.order(:end_date).last.try(:end_date)
  end

  def active
    !churned
  end

  def churned
    customer_end_date && customer_end_date < Date.today
  end

  def has_start_and_end
    !!(customer_start_date and customer_end_date)
  end

  def primary_contact
    users.first.try(:name) || "*No Primary Contact*"
  end

  def life_time
    TimeDifference.between(customer_start_date, customer_end_date).in_months
  end

  def oldest_demo
    @oldest_demo ||= demos.order('created_at ASC').first
  end

  def user_activation_rate
    if users.count.nonzero?
      (activated_users.count.to_f / users.count) * 100
    else
      0
    end
  end

  def activated_users
    arel_users = User.arel_table
    users.non_site_admin.where(arel_users[:accepted_invitation_at].not_eq(nil))
  end

end
