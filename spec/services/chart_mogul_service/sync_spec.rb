require 'spec_helper'

describe ChartMogulService::Sync do
  let(:organization) { Organization.create(name: "Test") }
  let(:plan) { SubscriptionPlan.create(name: "Test Plan", interval_count: 1, interval_cd: 0) }
  let(:subscription) { Subscription.create(subscription_plan: plan, organization: organization) }

  let(:invoice) { subscription.invoices.create(
    amount_in_cents: 1000,
    service_period_start: Date.today,
    service_period_end: Date.today + 1.year
  ) }

  let(:transaction) { invoice.find_or_create_payment }

  let(:cm_sync_service) { ChartMogulService::Sync.new(organization: organization) }

  describe "#sync" do
    it "calls #update_customer_attrs" do
      cm_sync_service.stubs(:delay).returns(stub_everything)
      cm_sync_service.expects(:update_customer_attrs).once

      cm_sync_service.sync
    end

    it "calls #update_invoices in the background" do
      cm_sync_service.stubs(:update_customer_attrs)
      cm_sync_service.stubs(:delay).returns(cm_sync_service)
      cm_sync_service.expects(:update_invoices).once

      cm_sync_service.sync
    end
  end

  describe "#update_invoices" do
    it "asks ChartMogulService::Invoice to create_subscription_invoice" do
      transaction.stubs(:create_invoice_transaction_in_chart_mogul)

      ChartMogulService::Invoice.expects(:create_subscription_invoice).with(invoice: invoice).once

      cm_sync_service.update_invoices
    end

    it "asks invoice to find_or_create_payment" do
      transaction.stubs(:create_invoice_transaction_in_chart_mogul)
      ChartMogulService::Invoice.stubs(:create_subscription_invoice)

      Invoice.any_instance.expects(:find_or_create_payment).once.returns(transaction)

      cm_sync_service.update_invoices
    end

    it "asks the payment to sync itself with ChartMogul" do
      transaction
      ChartMogulService::Invoice.stubs(:create_subscription_invoice)
      InvoiceTransaction.any_instance.expects(:create_invoice_transaction_in_chart_mogul).once

      cm_sync_service.update_invoices
    end

    it "asks to update subscriptions" do
      cm_sync_service.expects(:update_subscriptions)

      cm_sync_service.update_invoices
    end
  end

  describe "#update_customer_attrs" do
    it "asks an instance of ChartMogulService::Customer to create_or_update_chart_mogul_customer" do
      ChartMogulService::Customer.any_instance.expects(:create_or_update_chart_mogul_customer).once

      cm_sync_service.send(:update_customer_attrs)
    end
  end

  describe "#update_subscriptions" do
    it "asks subscriptions that are cancelled to update themselves in ChartMogul" do
      invoice
      fake_chart_mogul_subscription_service = OpenStruct.new

      subscription.update_attributes(cancelled_at: Date.today + 2.weeks)
      cancelled_subscription = subscription

      ongoing_subscription =  Subscription.create(subscription_plan: plan, organization: organization)

      ChartMogulService::Subscription.expects(:new).with(subscription: ongoing_subscription).never
      ChartMogulService::Subscription.expects(:new).with(subscription: cancelled_subscription).once.returns(fake_chart_mogul_subscription_service)

      fake_chart_mogul_subscription_service.expects(:cancel)

      cm_sync_service.send(:update_subscriptions)
    end
  end
end
