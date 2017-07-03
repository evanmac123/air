class ChartMogulService::Remove
  attr_reader :organization

  def initialize(organization:)
    @organization = organization
  end

  def remove_from_chart_mogul
    ChartMogulService::Customer.new(organization: organization).destroy_chart_mogul_customer
  end

  def remove_chart_mogul_uuids
    organization.update_attributes(chart_mogul_uuid: nil)
    invoices.update_all(chart_mogul_uuid: nil)
    invoice_transactions.update_all(chart_mogul_uuid: nil)
  end

  private

    def invoices
      organization.invoices
    end

    def invoice_transactions
      organization.invoice_transactions
    end
end
