class ChartMogulService::Invoice
  attr_reader :invoice, :organization, :plan, :subscription

  def self.create_subscription_invoice(invoice: invoice)
    chart_mogul_service = ChartMogulService::Invoice.new(invoice: invoice)
    chart_mogul_service.create_subscription_invoice
  end

  def initialize(invoice: invoice)
    @invoice = invoice
    @organization = invoice.organization
    @subscription = invoice.subscription
    @plan = subscription.subscription_plan
  end

  def create_subscription_invoice
    return false unless can_create_chart_mogul_invoice?
    chart_mogul_line_item = build_subscription_invoice_line_item

    chart_mogul_invoice = build_subscription_invoice(line_item: chart_mogul_line_item)

    result = ChartMogul::CustomerInvoices.create!(
      customer_uuid: organization.chart_mogul_uuid,
      invoices: [chart_mogul_invoice]
    )
    if result
      invoice.update_attributes(chart_mogul_uuid: result.invoices.first.uuid)
    end
  end

  private

    def can_create_chart_mogul_invoice?
      organization.chart_mogul_uuid && plan.chart_mogul_uuid
    end

    def get_customer(organization)
      ChartMogulService::Customer.new(organization).find_or_create_customer
    end

    def get_plan(plan)
      ChartMogulService::Plan.new(plan).find_plan_by_name(internal_plan_name)
    end

    def build_subscription_invoice_line_item
      ChartMogul::LineItems::Subscription.new(
        subscription_external_id: subscription.id,
        plan_uuid: plan.chart_mogul_uuid,
        service_period_start: invoice.service_period_start.utc,
        service_period_end: invoice.service_period_end.utc,
        amount_in_cents: invoice.amount_in_cents,
      )
    end

    def build_subscription_invoice(line_item:)
      ChartMogul::Invoice.new(
      	external_id: invoice.id,
        date: invoice.created_at.utc,
        currency: 'USD',
        due_date: invoice.service_period_start.utc,
        line_items: [line_item]
      )
    end
end
