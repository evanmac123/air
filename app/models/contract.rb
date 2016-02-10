class Contract < ActiveRecord::Base
  belongs_to :organization
  belongs_to :parent_contract, class_name: "Contract"
  has_many :child_contracts, class_name: "Contract", foreign_key: "parent_contract_id"

  validates :organization, :name, :start_date, :end_date, :max_users, :term, :estimate_type, :plan, presence: true
  validates :parent_contract,presence: true, if: :is_upgrade

  validates :max_users, :term, numericality: { only_integer: true }
  validates :arr, :mrr, numericality: true, allow_nil: true
  validate :arr_or_mrr_provided

  PLANS= ["Activate", "Engage", "Enterprise"] 
  ESTIMATE_TYPE= ["Actual", "Projected"] 

  def self.plans
    {activate: "Activate", engage: "Engage", enterprise: "Enterprise"}
  end

  def self.plan_name_for key
   plans[key]  
  end

  private
  def arr_or_mrr_provided
    if !(arr || mrr)
      errors.add(:mrr,"ARR or MRR must be provided") 
      return false
    end
  end

end
