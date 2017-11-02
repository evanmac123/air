require 'spec_helper'

describe ChartMogulService::Invoice do
  let(:organization) { Organization.create(name: "Test", chart_mogul_uuid: "cm_org_uuid") }
  let(:plan) { SubscriptionPlan.create(name: "Test Plan", interval_count: 1, interval_cd: 0) }
  let(:subscription) { Subscription.create(subscription_plan: plan, organization: organization) }

  let(:invoice) { subscription.invoices.create(
    amount_in_cents: 1000,
    service_period_start: Date.current,
    service_period_end: Date.current + 1.year
  ) }

  let(:cm_invoice_service) { ChartMogulService::Invoice.new(invoice: invoice) }

  describe ".create_subscription_invoice" do
    it "initializes a ChartMogulService::Invoice and asks it to create_subscription_invoice" do
      ChartMogulService::Invoice.any_instance.expects(:create_subscription_invoice).once

      ChartMogulService::Invoice.create_subscription_invoice(invoice: invoice)
    end
  end

  describe "#create_subscription_invoice" do
    it "returns false if can_create_chart_mogul_invoice? is false" do
      cm_invoice_service.stubs(:can_create_chart_mogul_invoice?).returns(false)

      expect(cm_invoice_service.create_subscription_invoice).to eq(false)
    end

    it "builds an invoice, sends it to ChartMogul and updates the internal invoice with the ChartMogul invoice uuid" do
      cm_invoice_service.stubs(:can_create_chart_mogul_invoice?).returns(true)

      cm_invoice_service.expects(:build_subscription_invoice_line_item).once.returns(:cm_line_item)

      cm_invoice_service.expects(:build_subscription_invoice).with(line_item: :cm_line_item).once.returns(:cm_invoice)

      ChartMogul::CustomerInvoices.expects(:create!).once.with(customer_uuid: organization.chart_mogul_uuid, invoices: [:cm_invoice]).returns(OpenStruct.new(invoices: [OpenStruct.new(uuid: "cm_invoice_uuid")]))

      invoice.expects(:update_attributes).once.with(chart_mogul_uuid: "cm_invoice_uuid")

      cm_invoice_service.create_subscription_invoice
    end
  end

  describe "#remove_invoice" do
    it "asks ChartMogul to remove the invoice" do
      invoice.update_attributes(chart_mogul_uuid: "cm_invoice_uuid")

      ChartMogul::Invoice.expects(:destroy!).with(uuid: "cm_invoice_uuid").once

      cm_invoice_service.remove_invoice
    end
  end

  describe "#can_create_chart_mogul_invoice" do
    it "returns true if the organization has a chart_mogul_uuid and the plan has a chart_mogul_uuid" do
      cm_invoice_service
      Organization.any_instance.expects(:chart_mogul_uuid).returns(true)
      SubscriptionPlan.any_instance.expects(:chart_mogul_uuid).returns(true)

      expect(cm_invoice_service.send(:can_create_chart_mogul_invoice?)).to eq(true)
    end

    it "returns falsey if the plan does not have a chart_mogul_uuid" do
      cm_invoice_service
      Organization.any_instance.expects(:chart_mogul_uuid).returns(true)
      SubscriptionPlan.any_instance.expects(:chart_mogul_uuid).returns(nil)

      expect(cm_invoice_service.send(:can_create_chart_mogul_invoice?)).to eq(nil)
    end

    it "returns falsey if the organization does not have a chart_mogul_uuid" do
      cm_invoice_service
      Organization.any_instance.expects(:chart_mogul_uuid).returns(nil)

      expect(cm_invoice_service.send(:can_create_chart_mogul_invoice?)).to eq(nil)
    end
  end

  describe "#build_subscription_invoice_line_item" do
    it "asks ChartMogul to build a new line_item" do
      ChartMogul::LineItems::Subscription.expects(:new).with(
        subscription_external_id: subscription.id,
        plan_uuid: plan.chart_mogul_uuid,
        service_period_start: invoice.service_period_start,
        service_period_end: invoice.service_period_end,
        amount_in_cents: invoice.amount_in_cents
      )

      cm_invoice_service.send(:build_subscription_invoice_line_item)
    end
  end

  describe "#build_subscription_invoice" do
    it "asks ChartMogul to build a new invoice" do
      fake_chart_mogul_line_item = OpenStruct.new

      ChartMogul::Invoice.expects(:new).with(
        external_id: invoice.id,
        date: invoice.created_at,
        currency: 'USD',
        due_date: invoice.service_period_start,
        line_items: [fake_chart_mogul_line_item]
      )

      cm_invoice_service.send(:build_subscription_invoice, line_item: fake_chart_mogul_line_item)
    end
  end
end
