class ChartMogulService::Subscription
  attr_reader   :subscription, :organization
  attr_accessor :chart_mogul_customer

  def initialize(subscription:)
    @subscription = subscription
    @organization = subscription.organization
    @chart_mogul_customer = retrieve_customer
  end

  def cancel
    if chart_mogul_customer
      cm_subscription = chart_mogul_customer.subscriptions.find { |s| s.external_id == subscription_id.to_s }

      cm_subscription.cancel(subscription.cancelled_at)
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

    def subscription_id
      subscription.id
    end
end
