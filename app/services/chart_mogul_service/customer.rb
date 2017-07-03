class ChartMogulService::Customer
  attr_accessor :chart_mogul_customer
  attr_reader   :organization

  def initialize(organization:)
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

  def create_or_update_chart_mogul_customer
    if chart_mogul_customer
      self.update_chart_mogul_customer
    else
      self.create_chart_mogul_customer
    end
  end

  def update_chart_mogul_customer
    chart_mogul_customer.name = organization.name
    chart_mogul_customer.email = organization.email
    chart_mogul_customer.free_trial_started_at = organization.free_trial_started_at

    chart_mogul_customer.update!
  end

  def create_chart_mogul_customer
    @chart_mogul_customer = ChartMogul::Customer.create!(
      data_source_uuid: ChartMogul::DEFAULT_DATA_SOURCE,
      external_id: organization.id,
      name: organization.name,
      email: organization.email,
      lead_created_at: organization.created_at,
      free_trial_started_at: organization.free_trial_started_at
    )

    add_chart_mogul_uuid_to_org if chart_mogul_customer
    chart_mogul_customer
  end

  def destroy_chart_mogul_customer
    if chart_mogul_customer.is_a?(ChartMogul::Customer)
      chart_mogul_customer.destroy!
    end
  end

  private

    def retrieve_customer
      if organization.chart_mogul_uuid
        begin
          ChartMogul::Customer.retrieve(organization.chart_mogul_uuid)
        rescue
          return false
        end
      end
    end

    def add_chart_mogul_uuid_to_org
      if chart_mogul_customer.is_a?(ChartMogul::Customer)
        organization.update_attributes(chart_mogul_uuid: chart_mogul_customer.uuid)
      end
    end
end
