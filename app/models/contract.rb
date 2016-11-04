class Contract < ActiveRecord::Base
  belongs_to :organization
  belongs_to :parent_contract, class_name: "Contract"
  has_many :upgrades, class_name: "Contract", foreign_key: "parent_contract_id"
  has_many :billings

  validates :organization, :name, :start_date, :end_date, :max_users, :amt_booked, :cycle, :plan, presence: true
  validates :term, presence: true, if: Proc.new{|c|c.cycle == CUSTOM}
  validates :max_users, numericality: { only_integer: true }
  validates :arr, :mrr, numericality: true, allow_nil: true
  validate :arr_or_mrr_provided

  ANNUAL="Annual"
  MONTHLY="Monthly"
  QUARTERLY="Quarterly"
  SEMI_ANNUAL="Semi Annual"
  CUSTOM = "Custom"
   
  before_validation :set_name

  def self.upgrades
    where("parent_contract_id is not NULL")
  end

  def self.current
    where(in_collection: false)
  end

  def self.current_as_of d
    where("delinquency_date is null or delinquency_date > ?", d)
  end

  def self.delinquent_as_of d
    where("delinquency_date  <= ?", d)
  end
  def self.delinquent
    where(in_collection: true)
  end

  def self.auto_renewing
    where(auto_renew: true)
  end

  def self.cancelled
    where(auto_renew: false)
  end

  def self.active
    current.where("end_date >= ?", Date.today)
  end

  def self.inactive
    where("end_date < ?", Date.today)
  end

  def self.active_mrr_today
   active.sum(&:calc_mrr)
  end

  def self.active_arr_today
    active.sum(&:calc_mrr) * 12
  end

  def self.delinquent_mrr_as_of_date d
    delinquent_as_of(d).sum(&:calc_mrr) 
  end


  #--------------------------------------------------------
  # Used for forecasting and historical analysis
  #--------------------------------------------------------
 
  def self.active_as_of_date d
    current_as_of(d).where("end_date >= ? and start_date <= ?", d, d)
  end

  def self.active_during_period sdate, edate
    current_as_of(sdate).where("start_date <= ? and end_date >= ?", sdate, sdate)
  end

  def self.active_not_expiring_during_period sdate, edate
    current_as_of(sdate).where("start_date <= ? and end_date >= ?", edate, edate)
  end

  def self.added_during_period sdate, edate
    where("start_date >= ? and start_date <= ?", sdate, edate)
  end

  def self.expiring_during_period sdate, edate
    where("end_date >= ? and end_date <= ?", sdate, edate)
  end

  def self.active_mrr_as_of_date report_date=Date.today
    active_as_of_date(report_date).sum(&:calc_mrr)
  end

  def self.mrr_during_period sdate, edate
    active_during_period(sdate, edate).sum(&:calc_mrr)
  end

  def self.mrr_added_during_period sdate, edate
    added_during_period(sdate, edate).sum(&:calc_mrr)
  end

  def self.mrr_possibly_churning_during_period sdate, edate 
    expiring_during_period(sdate, edate).sum(&:calc_mrr)
  end

  def self.booked_during_period sdate, edate
    where("date_booked >= ? and date_booked <= ?", sdate, edate).sum(&:amt_booked)
  end

  def self.active_booked_for_date start_date=Date.today
    active_as_of_date(start_date).sum(&:amt_booked)
  end

  def self.booked_year_to_date date=Date.today
    where("date_booked >= ? and date_booked <= ?", date.beginning_of_year, date).sum(&:amt_booked)
  end



  def self.min_activity_date
    min_start = minimum(:start_date)
    min_booked =  minimum(:date_booked)
    min_start < min_booked ? min_start : min_booked
  end

  def status
    end_date >= Date.today ? "Active" : "Closed"
  end

  def projection_type
    is_actual ? "Actual" : "Projection"
  end

  def role_type
    is_upgrade ? "Upgrade" : "Primary"
  end

  def contract_length_in_months
    TimeDifference.between(end_date, start_date).in_months
  end

  def organization_name
    organization.name
  end

  def renew
    dup = self.dup
    dup.start_date = end_date.advance(days:1)
    dup.end_date = new_end_date(end_date)
    dup.date_booked = dup.start_date
    dup.save
    dup
  end


 def calc_mrr
   if (mrr || arr)
     mrr || arr/12 
   end
 end

  def calc_arr
    if(mrr || arr)
      arr || mrr*12
    end
  end

  def pepm
    calc_mrr/max_users
  end

  def calculated_rr
    if mrr || arr
      arr.nil? ? (mrr*12).to_i :  (arr/12).to_i
    end
  end

  def booked_months
   amt_booked/calc_mrr
  end

  def revenue_basis
    mrr.present? ? "monthly" : "annual"
  end

  def alt_revenue_basis
    revenue_basis == "monthly" ? "Annual" : "Monthly"
  end

  private

  def set_name
    self.name = "#{organization_name}: #{start_date}-#{end_date}"
  end

  def new_end_date date
    e = cal_end_date date 
    if is_last_day(end_date) && !is_last_day(e)
      e.end_of_month
    else
      e
    end 
  end

  def cal_end_date new_start

    d = case cycle 
        when ANNUAL
          new_start.advance(years:1)
        when SEMI_ANNUAL
          new_start.advance(months:6)
        when QUARTERLY
          new_start.advance(months:3)
        when MONTHLY
          new_start.advance(months:1)
        when CUSTOM
          new_start.advance(months: contract_length_in_months)
        end
  end

  def arr_or_mrr_provided
    if !(arr || mrr)
      errors.add(:mrr,"ARR or MRR must be provided") 
      return false
    end
  end

  def is_upgrade
    parent_contract.present?
  end

  def is_last_day(mydate)
    mydate.month != mydate.next_day.month 
  end

end
