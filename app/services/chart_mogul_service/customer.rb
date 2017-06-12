class ChartMogulService::Customer
  attr_accessor :chart_mogul_customer, :organization

  def initialize(organization: organization)
    @organization = organization
    @chart_mogul_customer = retrieve_customer
  end

  def find_or_create_chart_mogul_customer
    if chart_mogul_customer
      chart_mogul_customer
    else
      self.create_chart_mogul_customer
    end
  end

  def create_chart_mogul_customer
    @chart_mogul_customer = ChartMogul::Customer.create!(
      data_source_uuid: ChartMogul::DEFAULT_DATA_SOURCE,
      external_id: organization.id,
      name: organization.name
    )

    add_chart_mogul_uuid_to_org if chart_mogul_customer
    chart_mogul_customer
  end

  def destroy_chart_mogul_customer
    if chart_mogul_customer.is_a?(ChartMogul::Customer)
      if chart_mogul_customer.destroy!
        @chart_mogul_customer = nil
        organization.update_attributes(chart_mogul_uuid: nil)
      else
        return false
      end
    end
  end

  private

    def retrieve_customer
      if organization.chart_mogul_uuid
        ChartMogul::Customer.retrieve(organization.chart_mogul_uuid)
      end
    end

    def add_chart_mogul_uuid_to_org
      if chart_mogul_customer.is_a?(ChartMogul::Customer)
        organization.update_attributes(chart_mogul_uuid: chart_mogul_customer.uuid)
      end
    end
end
