require 'spec_helper'

describe ChartMogulService::Subscription do
  let(:organization) { Organization.create(name: "Test") }
  let(:plan) { SubscriptionPlan.create(name: "Test Plan", interval_count: 1, interval_cd: 0) }
  let(:subscription) { Subscription.create(subscription_plan: plan, organization: organization) }

  describe "#cancel" do
    describe "when a chart_mogul_customer exists" do
      it "asks the chart_mogul_customer to find a subscription that matches our internal subscription id and calls cancel on it" do
        subscription.update_attribute(:cancelled_at, Date.tomorrow)

        cm_subscription_service = ChartMogulService::Subscription.new(subscription: subscription)

        fake_cm_subscription_1 = OpenStruct.new(external_id: subscription.id.to_s, cancel: true)

        fake_cm_subscription_2 = OpenStruct.new(external_id: "0", cancel: true)

        fake_cm_customer = OpenStruct.new(subscriptions: [fake_cm_subscription_2, fake_cm_subscription_1])

        cm_subscription_service.chart_mogul_customer = fake_cm_customer

        fake_cm_subscription_1.expects(:cancel).once.with(subscription.cancelled_at)
        fake_cm_subscription_2.expects(:cancel).never

        cm_subscription_service.cancel
      end
    end

    describe "when a chart_mogul_customer does not exist" do
      it "does nothing" do
        cm_subscription_service = ChartMogulService::Subscription.new(subscription: subscription)

        expect(cm_subscription_service.cancel).to eq(nil)
      end
    end
  end

  describe "#retrieve_customer" do
    describe "when initialized" do
      it "calls retrieve_customer" do
        ChartMogulService::Subscription.any_instance.expects(:retrieve_customer).once

        ChartMogulService::Subscription.new(subscription: subscription)
      end

      it "asks ChartMogul::Customer to retrieve a chart_mogul_customer by chart_mogul_uuid" do
        organization.update_attributes(chart_mogul_uuid: "fake_chart_mogul_uuid")

        ChartMogul::Customer.expects(:retrieve).once.with("fake_chart_mogul_uuid")

        ChartMogulService::Subscription.new(subscription: subscription)
      end
    end
  end
end
