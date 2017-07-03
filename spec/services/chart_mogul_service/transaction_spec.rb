require 'spec_helper'

describe ChartMogulService::Transaction do
  let(:organization) { Organization.create(name: "Test") }
  let(:plan) { SubscriptionPlan.create(name: "Test Plan", interval_count: 1, interval_cd: 0) }
  let(:subscription) { Subscription.create(subscription_plan: plan, organization: organization) }

  let(:invoice) { subscription.invoices.create(
    amount_in_cents: 1000,
    service_period_start: Date.today,
    service_period_end: Date.today + 1.year
  ) }

  let(:transaction) { invoice.find_or_create_payment }

  describe ".create_payment" do
    it "asks ChartMogul to create a payment" do
      invoice.update_attributes(chart_mogul_uuid: "test_uuid")

      ChartMogul::Transactions::Payment.expects(:create!).with(
        invoice_uuid: "test_uuid",
        external_id: transaction.id,
        date: transaction.paid_date_or_invoice_due_date,
        result: 'successful'
      ).once

      ChartMogulService::Transaction.create_payment(transaction: transaction, invoice: invoice)
    end

    it "updates transaction with returned chart_mogul_uuid" do
      ChartMogul::Transactions::Payment.expects(:create!).returns(OpenStruct.new(uuid: "test_transaction_uuid"))

      ChartMogulService::Transaction.create_payment(transaction: transaction, invoice: invoice)

      expect(transaction.chart_mogul_uuid).to eq("test_transaction_uuid")
    end
  end
end
