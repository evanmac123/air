class ContractRenewer

  def self.execute
    Contract.active_as_of_date(Date.today).auto_renewing.each do |contract|
      if contract.end_date.end_of_day <= 1.week.from_now.end_of_day
        contract.renew
      end
    end
  end

end
