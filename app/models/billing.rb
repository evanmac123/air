class Billing < ActiveRecord::Base
  belongs_to :contract
  validates :contract, presence: true

  def contract_name
    contract.name
  end

  def organization_name
    contract.organization_name
  end
end
