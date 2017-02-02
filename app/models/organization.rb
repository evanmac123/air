class Organization < ActiveRecord::Base
  resourcify
  before_save :update_slug

  has_many :contracts
  has_many :demos, autosave: true, dependent: :destroy
  has_many :lead_contacts, dependent: :destroy
  has_many :boards, class_name: :Demo, autosave: true
  has_many :tiles, through: :boards
  has_many :board_memberships, through: :boards
  has_many :users
  has_one :onboarding, autosave: true

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  accepts_nested_attributes_for :boards
  accepts_nested_attributes_for :users

  scope :name_order, -> { order(:name) }

  def update_slug
    self.slug = name.parameterize
  end

  def to_param
    self.slug
  end

  def self.as_customer
    joins(:contracts).uniq
  end

  def self.active_as_of_date d
    as_customer.select{|o| o.active_as_of_date(d)}
  end

  def self.with_active_contracts date
    org_table = Organization.arel_table
    contract_table = Contract.arel_table

    self.select(org_table[:name]).joins(
      org_table.join(contract_table).on(
        org_table[:id].eq(contract_table[:organization_id]).and(
          contract_table[:end_date].gteq(date).and(contract_table[:in_collection].eq(false))
        )
      ).join_sources
    ).uniq
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
    @cust_start ||=ordered_contracts.first.try(:start_date)
  end

  def customer_end_date
    @cust_end ||= ordered_contracts.last.try(:end_date)
  end

  def active
    !churned
  end

  def churned
    customer_end_date && customer_end_date < Date.today
  end

  def has_start_and_end
    customer_start_date && customer_end_date
  end

  def primary_contact
    users.first.try(:name) || "*No Primary Contact*"
  end

  def life_time
    TimeDifference.between(customer_start_date, customer_end_date).in_months
  end



  private

  def create_default_board_membership
    if users.first && demos.first
      bm = BoardMembership.new
      bm.user = users.first
      bm.demo = demos.first
      bm.save
    end
  end

  def ordered_contracts
    contracts.order("start_date asc")
  end

end
