class ChartMogulService::Invoice
  attr_reader :invoice, :organization, :plan, :subscription

  def self.create_subscription_invoice(invoice:)
    chart_mogul_service = ChartMogulService::Invoice.new(invoice: invoice)
    chart_mogul_service.create_subscription_invoice
  end

  def initialize(invoice:)
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
      result
    end
  end

  def remove_invoice
    begin
      ChartMogul::Invoice.destroy!(uuid: invoice.chart_mogul_uuid)
    rescue ChartMogul::NotFoundError
      return true
    end
  end

  private

    def can_create_chart_mogul_invoice?
      organization.chart_mogul_uuid && plan.chart_mogul_uuid
    end

    def build_subscription_invoice_line_item
      ChartMogul::LineItems::Subscription.new(
        subscription_external_id: subscription.id,
        plan_uuid: plan.chart_mogul_uuid,
        service_period_start: invoice.service_period_start,
        service_period_end: invoice.service_period_end,
        amount_in_cents: invoice.amount_in_cents,
      )
    end

    def build_subscription_invoice(line_item:)
      ChartMogul::Invoice.new(
      	external_id: invoice.id,
        date: invoice.created_at,
        currency: 'USD',
        due_date: invoice.service_period_start,
        line_items: [line_item]
      )
    end
end
