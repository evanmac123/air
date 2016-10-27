class Organization < ActiveRecord::Base
  serialize :roles, Array

  has_many :contracts
  has_many :demos, autosave: true
  has_many :lead_contacts
  has_many :boards, class_name: :Demo, autosave: true

  has_many :users do
    def first_or_build(attrs)
      where(email: attrs[:email]).first || build(attrs)
    end
  end

  has_one :onboarding, autosave: true do
    def get_or_build(attrs)
       self || build(attrs)
    end
  end


  validates :name, presence: true, uniqueness: true
  accepts_nested_attributes_for :demos
  accepts_nested_attributes_for :users

  scope :name_order, ->{order("LOWER(name)")}


  def self.as_customer
    joins(:contracts).uniq
  end

  def self.active_as_of_date d
    as_customer.select{|o| o.active_as_of_date(d)}
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


  #-----------

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


#------------------WIP-----------------------------------------


 #NOTE customer will not show up as possible churn if they have 1 or more
  #contracts expiring after edate. Their contracts will be included in possible
  #churned
  #
  #



  def self.possible_churn_during_period sdate, edate
    as_customer.select{|o| o.has_start_and_end && o.customer_end_date > sdate && o.customer_end_date <= edate}
  end

  def self.mrr_possibly_churning_during_period sdate, edate
    possible_churn_during_period(sdate, edate)
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

  def arr_during_period sdate, edate
    contracts.arr_during_period(sdate, edate)
  end

  def mrr_during_period sdate, edate
    contracts.mrr_during_period(sdate, edate)
  end

  def self.active_after_date date
    joins(:contracts)
      .select("organizations.id, organizations.name")
      .where("contracts.end_date > ?", date)
      .group("organizations.id, organizations.name")
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
