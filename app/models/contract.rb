class Contract < ActiveRecord::Base
  belongs_to :organization
  belongs_to :parent_contract, class_name: "Contract"
  has_many :child_contracts, class_name: "Contract", foreign_key: "parent_contract_id"

  validates :organization, :name, :start_date, :end_date, :max_users, :term, :plan, presence: true

  validates :max_users, :term, numericality: { only_integer: true }
  validates :arr, :mrr, numericality: true, allow_nil: true
  validate :arr_or_mrr_provided

  def status
    end_date > Date.today ? "Active" : "Closed"
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

  def calc_mrr
     mrr || arr/12 
  end

  def calc_arr
     arr || mrr*12
  end

  def pepm
    calc_mrr/max_users
  end

  def calculated_rr
    arr.nil? ? (mrr*12).to_i :  (arr/12).to_i
  end

  def booked_months
   amt_booked/calc_mrr
  end


  private

  def arr_or_mrr_provided
    if !(arr || mrr)
      errors.add(:mrr,"ARR or MRR must be provided") 
      return false
    end
  end

  def is_upgrade
    parent_contract.present?
  end

end
