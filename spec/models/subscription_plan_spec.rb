require 'rails_helper'

RSpec.describe SubscriptionPlan, type: :model do
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_uniqueness_of(:name) }
  it { is_expected.to validate_presence_of(:interval_cd) }
  it { is_expected.to validate_presence_of(:interval_count) }
  it { is_expected.to have_many(:subscriptions) }

  describe "#create_chart_mogul_plan" do
    it "asks the ChartMogulService::Plan to create a plan in the background" do
      plan = SubscriptionPlan.create(name: "Test Plan", interval_count: 1, interval_cd: 0)

      ChartMogulService::Plan.stubs(:delay).returns(ChartMogulService::Plan)
      ChartMogulService::Plan.stubs(:dispatch_create)

      plan.create_chart_mogul_plan

      expect(ChartMogulService::Plan).to have_received(:delay)
      expect(ChartMogulService::Plan).to have_received(:dispatch_create).with(subscription_plan: plan)
    end
  end

  describe "#update_chart_mogul_plan_name" do
    it "asks the ChartMogulService::Plan to update a plan in the background" do
      plan = SubscriptionPlan.create(name: "Test Plan", interval_count: 1, interval_cd: 0)

      ChartMogulService::Plan.stubs(:delay).returns(ChartMogulService::Plan)
      ChartMogulService::Plan.stubs(:dispatch_update)

      plan.update_chart_mogul_plan_name

      expect(ChartMogulService::Plan).to have_received(:delay)
      expect(ChartMogulService::Plan).to have_received(:dispatch_update).with(subscription_plan: plan)
    end
  end
end
