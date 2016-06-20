class ContractRenewer

  def self.execute
    Contract.active.auto_renewing.each do |contract|
      if contract.end_date ==Date.today
        contract.renew
      end
    end
  end

end
