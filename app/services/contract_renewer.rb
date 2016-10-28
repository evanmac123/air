class ContractRenewer

  def self.execute
    Contract.active_as_of_date(Date.today).auto_renewing.each do |contract|
      if contract.end_date ==Date.tomorrow
        contract.renew
      end
    end
  end

end
