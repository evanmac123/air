class ChartMogulService::Sync
  attr_reader :organization

  def initialize(organization:)
    @organization = organization
  end

  def sync
    update_customer_attrs
    delay.update_invoices
  end

  def update_invoices
    organization.invoices.where(chart_mogul_uuid: nil).each do |invoice|
      ChartMogulService::Invoice.create_subscription_invoice(invoice: invoice)

      payment = invoice.find_or_create_payment
      payment.create_invoice_transaction_in_chart_mogul
    end

    update_subscriptions
  end

  private

    def update_subscriptions
      organization.subscriptions.where("cancelled_at IS NOT NULL").each do |subscription|
        ChartMogulService::Subscription.new(subscription: subscription).cancel
      end
    end

    def update_customer_attrs
      ChartMogulService::Customer.new(organization: organization).create_or_update_chart_mogul_customer
    end
end
