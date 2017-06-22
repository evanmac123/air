require 'rails_helper'

RSpec.describe Invoice, type: :model do
  describe "instance methods" do
    before do
      organization = Organization.create(name: "Test")
      plan = SubscriptionPlan.create(name: "Test Plan", interval_count: 1, interval_cd: 0)
      subscription = Subscription.create(subscription_plan: plan, organization: organization)

      @invoice = subscription.invoices.create(
      amount_in_cents: 1000,
      service_period_start: Date.today,
      service_period_end: Date.today + 1.year
      )
    end

    subject { @invoice }

    it { is_expected.to belong_to(:subscription) }
    it { is_expected.to have_many(:invoice_transactions).dependent(:destroy) }
    it { is_expected.to validate_presence_of(:subscription) }
    it { is_expected.to validate_presence_of(:amount_in_cents) }
    it { is_expected.to validate_presence_of(:type_cd) }

    describe "#calculate_service_period_end" do
      it "should calculate_service_period_end based on current plan" do
        plan = @invoice.plan
        plan.interval = :year
        plan.interval_count = 1
        plan.save

        @invoice.update_attributes(service_period_start: Time.local(2010, 2, 15))
        new_end_date = Time.local(2010, 2, 15) + 1.year

        expect(@invoice.calculate_service_period_end).to eq(new_end_date)
      end
    end

    describe "#plan" do
      describe "when an invoice has a subscription" do
        it "returns the subcription_plan" do
          plan = @invoice.subscription.subscription_plan
          expect(@invoice.plan).to eq(plan)
        end
      end

      describe "when an invoice does not have a plan" do
        it "returns nil" do
          invoice = Invoice.new

          expect(invoice.plan).to eq(nil)
        end
      end
    end

    describe "#create_subscription_invoice_in_chart_mogul" do
      it "asks ChartMogulService to create an invoice in ChartMogul" do
        ChartMogulService::Invoice.expects(:create_subscription_invoice).with(invoice: @invoice).once

        @invoice.create_subscription_invoice_in_chart_mogul
      end
    end

    describe "#organization" do
      it "returns the subscription organization" do
        subscription = @invoice.subscription
        expect(@invoice.organization).to eq(subscription.organization)
      end
    end

    describe "#subscription_id" do
      it "returns the subscription id" do
        subscription = @invoice.subscription
        expect(@invoice.subscription_id).to eq(subscription.id)
      end
    end

    describe "#find_or_create_payment" do
      it "returns any related payments" do
        @invoice.find_or_create_payment

        payment = @invoice.invoice_transactions.paid.first

        expect(@invoice.find_or_create_payment).to eq(payment)
      end

      it "creates a payment if none exists" do
        expect(@invoice.invoice_transactions.empty?).to eq(true)

        @invoice.find_or_create_payment

        expect(@invoice.invoice_transactions.empty?).to eq(false)
        expect(@invoice.invoice_transactions.first.type).to eq(:payment)
      end
    end

    describe "#valid_service_dates" do
      it "adds error if service_period_start > service_period_end" do
        @invoice.service_period_end = @invoice.service_period_start - 1.day

        expect(@invoice.valid?).to eq(false)
        expect(@invoice.errors[:service_period_end]).to_not eq(nil)
      end
    end
  end

  describe "class methods" do
    before do
      Timecop.freeze(Time.now)
      organization = Organization.create(name: "Test")
      plan = SubscriptionPlan.create(name: "Test Plan", interval_count: 1, interval_cd: 0)
      subscription_1 = Subscription.create(subscription_plan: plan, organization: organization)
      subscription_2 = Subscription.create(subscription_plan: plan, organization: organization)

      @invoice_1 = subscription_1.invoices.create(
        amount_in_cents: 1000,
        service_period_start: Date.today - 1.year,
        service_period_end: Date.tomorrow
      )

      @invoice_2 = subscription_2.invoices.create(
        amount_in_cents: 1000,
        service_period_start: Date.today - 2.years,
        service_period_end: Date.tomorrow
      )

      @invoice_3 = subscription_1.invoices.create(
        amount_in_cents: 1000,
        service_period_start: Date.today,
        service_period_end: Date.today + 1.year
      )
    end

    after do
      Timecop.return
    end

    describe ".service_ends_tomorrow" do
      it "returns invoices that end service the next day" do
        expect(Invoice.service_ends_tomorrow.all).to eq([@invoice_1, @invoice_2])
      end
    end

    describe ".renew_active_invoices" do
      it "does not call .renew_invoice on active invoices if the subscription should not renew" do
        Subscription.any_instance.stubs(:should_renew_invoice?).returns(false)
        Invoice.expects(:renew_invoice).never

        Invoice.renew_active_invoices
      end

      it "calls .renew_invoice on active invoices if the subscription should renew" do
        Subscription.any_instance.stubs(:should_renew_invoice?).returns(true)
        Invoice.expects(:renew_invoice).with(original_invoice: @invoice_1)
        Invoice.expects(:renew_invoice).with(original_invoice: @invoice_2)

        Invoice.renew_active_invoices
      end
    end
  end
end
