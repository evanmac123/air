require 'rails_helper'

RSpec.describe InvoiceTransaction, :type => :model do
  it { is_expected.to validate_presence_of(:type_cd) }
  it { is_expected.to belong_to(:invoice) }

  describe "instance methods" do
    let(:organization) { Organization.create(name: "Test") }
    let(:plan) { SubscriptionPlan.create(name: "Test Plan", interval_count: 1, interval_cd: 0) }
    let(:subscription) { Subscription.create(subscription_plan: plan, organization: organization) }

    let(:invoice) { subscription.invoices.create(
      amount_in_cents: 1000,
      service_period_start: Date.current,
      service_period_end: Date.current + 1.year
    ) }

    describe "#create_invoice_transaction_in_chart_mogul" do
      it "calls ChartMogulService::Transaction.create_payment if successful? and invoice_is_in_chart_mogul?" do
        transaction = invoice.invoice_transactions.create

        transaction.stubs(:successful?).returns(true)
        transaction.stubs(:invoice_is_in_chart_mogul?).returns(true)

        ChartMogulService::Transaction.expects(:create_payment).with(transaction: transaction, invoice: invoice)

        transaction.create_invoice_transaction_in_chart_mogul
      end

      it "does not call ChartMogulService::Transaction.create_payment if not successful?" do
        transaction = invoice.invoice_transactions.create
        transaction.stubs(:successful?).returns(false)
        ChartMogulService::Transaction.expects(:create_payment).never

        transaction.create_invoice_transaction_in_chart_mogul
      end

      it "does not call ChartMogulService::Transaction.create_payment if not invoice_is_in_chart_mogul?" do
        transaction = invoice.invoice_transactions.create
        transaction.stubs(:invoice_is_in_chart_mogul?).returns(false)
        ChartMogulService::Transaction.expects(:create_payment).never

        transaction.create_invoice_transaction_in_chart_mogul
      end
    end

    describe "#successful?" do
      it "returns true if result is successful" do
        transaction = InvoiceTransaction.new(result_cd: InvoiceTransaction.successful)

        expect(transaction.successful?).to eq(true)
      end

      it "returns false if resutl is not successful" do
        transaction = InvoiceTransaction.new(result_cd: InvoiceTransaction.failed)

        expect(transaction.successful?).to eq(false)
      end
    end

    describe "#paid_date_or_invoice_due_date" do
      it "returns paid_date if present" do
        paid_date = Time.new(2013, 11, 3)
        transaction = invoice.invoice_transactions.new(paid_date: paid_date)

        expect(transaction.paid_date_or_invoice_due_date).to eq(paid_date)
      end

      it "returns invoice.service_period_start if paid_date is not present" do
        transaction = invoice.invoice_transactions.new

        expect(transaction.paid_date_or_invoice_due_date).to eq(invoice.service_period_start)
      end
    end

    describe "#invoice_is_in_chart_mogul" do
      it "returns true if the chart_mogul_uuid of the associated invoice is set" do
        invoice.update_attributes(chart_mogul_uuid: "test")
        transaction = invoice.invoice_transactions.new

        expect(transaction.invoice_is_in_chart_mogul?).to eq(true)
      end

      it "returns false if the chart_mogul_uuid of the associated invoice is not set" do
        invoice.update_attributes(chart_mogul_uuid: nil)
        transaction = invoice.invoice_transactions.new

        expect(transaction.invoice_is_in_chart_mogul?).to eq(false)
      end
    end
  end

  describe "class methods" do
    let(:organization) { Organization.create(name: "Test") }
    let(:plan) { SubscriptionPlan.create(name: "Test Plan", interval_count: 1, interval_cd: 0) }
    let(:subscription) { Subscription.create(subscription_plan: plan, organization: organization) }

    let(:invoice) { subscription.invoices.create(
      amount_in_cents: 1000,
      service_period_start: Date.current,
      service_period_end: Date.current + 1.year
    ) }

    let!(:paid_success_transaction_1) { invoice.invoice_transactions.create(type_cd: InvoiceTransaction.payment, result_cd: InvoiceTransaction.successful) }

    let!(:paid_success_transaction_2) { invoice.invoice_transactions.create(type_cd: InvoiceTransaction.payment, result_cd: InvoiceTransaction.successful) }

    let!(:paid_fail_transaction_1) { invoice.invoice_transactions.create(type_cd: InvoiceTransaction.payment, result_cd: InvoiceTransaction.failed) }

    let!(:refund_success_transaction_1) { invoice.invoice_transactions.create(type_cd: InvoiceTransaction.refund, result_cd: InvoiceTransaction.successful) }

    let!(:refund_fail_transaction_1) { invoice.invoice_transactions.create(type_cd: InvoiceTransaction.refund, result_cd: InvoiceTransaction.failed) }

    describe ".paid" do
      it "returns invoice_transactions that are both payments and are successful" do
        expect(InvoiceTransaction.paid.all).to eq([paid_success_transaction_1, paid_success_transaction_2])
      end
    end
  end
end
