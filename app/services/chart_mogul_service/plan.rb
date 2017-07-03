class ChartMogulService::Plan
  attr_reader   :subscription_plan
  attr_accessor :chart_mogul_plan

  def self.dispatch_create(subscription_plan:)
    ChartMogulService::Plan.new(subscription_plan).create_chart_mogul_plan_and_update_internal_plan
  end

  def self.dispatch_update(subscription_plan:)
    ChartMogulService::Plan.new(subscription_plan).update_chart_mogul_plan_name
  end

  def initialize(subscription_plan)
    @subscription_plan = subscription_plan
    @chart_mogul_plan  = find_plan_by_uuid
  end

  def create_chart_mogul_plan_and_update_internal_plan
    unless chart_mogul_plan
      create_chart_mogul_plan
      update_internal_plan_uuid
      chart_mogul_plan
    end
  end

  def update_chart_mogul_plan_name
    if chart_mogul_plan
      chart_mogul_plan.name = subscription_plan.name
      chart_mogul_plan.update!
    end
  end

  private

    def create_chart_mogul_plan
      @chart_mogul_plan = ChartMogul::Plan.create!(
        data_source_uuid: ChartMogul::DEFAULT_DATA_SOURCE,
        name: subscription_plan.name,
        interval_count: subscription_plan.interval_count,
        interval_unit: subscription_plan.interval,
        external_id: subscription_plan.id
      )
    end

    def update_internal_plan_uuid
      if chart_mogul_plan
        subscription_plan.update_attributes(chart_mogul_uuid: chart_mogul_plan.uuid)
      end
    end

    def find_plan_by_uuid
      if subscription_plan.chart_mogul_uuid
        ChartMogul::Plan.retrieve(subscription_plan.chart_mogul_uuid)
      end
    end
end
