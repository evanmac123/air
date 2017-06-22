require 'rails_helper'

RSpec.describe Subscription, type: :model do
  it { is_expected.to validate_presence_of(:organization) }
  it { is_expected.to validate_presence_of(:subscription_plan) }
  it { is_expected.to belong_to(:organization) }
  it { is_expected.to belong_to(:subscription_plan) }
  it { is_expected.to have_many(:invoices).dependent(:destroy) }

  describe "instance methods" do
    let(:organization) { Organization.create(name: "Test") }
    let(:plan) { SubscriptionPlan.create(name: "Test Plan", interval_count: 1, interval_cd: 0) }
    let(:subscription) { Subscription.create(subscription_plan: plan, organization: organization) }
    let(:invoice) { subscription.invoices.create(
      amount_in_cents: 1000,
      service_period_start: Date.today,
      service_period_end: Date.today + 1.year
    ) }

    describe "#should_renew_invoice" do
      let(:earlier_invoice) { subscription.invoices.create(
        amount_in_cents: 1000,
        service_period_start: Date.today - 6.months,
        service_period_end: Date.tomorrow
      ) }

      it "returns falsey if cancelled_at < invoice.service_period_end" do
        subscription.update_attributes(cancelled_at: invoice.service_period_end - 1.day)

        expect(subscription.should_renew_invoice?(invoice: invoice)).to eq(nil)
      end

      describe "not the latest invoice by invoice.service_period_end" do
        it "returns false if cancelled_at is nil" do
          invoice

          expect(subscription.should_renew_invoice?(invoice: earlier_invoice)).to eq(false)
        end

        it "returns false if cancelled_at > invoice.service_period_end" do
          invoice

          subscription.update_attributes(cancelled_at: earlier_invoice.service_period_end + 1.day)

          expect(subscription.should_renew_invoice?(invoice: earlier_invoice)).to eq(false)
        end
      end

      describe "latest invoice by invoice.service_period_end" do
        it "returns the true if cancelled_at is nil" do
          earlier_invoice

          subscription.update_attributes(cancelled_at: nil)

          expect(subscription.should_renew_invoice?(invoice: invoice)).to eq(true)
        end

        it "returns the true if cancelled_at > invoice.service_period_end" do
          earlier_invoice

          subscription.update_attributes(cancelled_at: invoice.service_period_end + 1.day)

          expect(subscription.should_renew_invoice?(invoice: earlier_invoice)).to eq(false)
        end
      end
    end

    describe "#cancelled_at_is_valid?" do
      it "returns no errors if cancelled_at.nil?" do
        subscription.update_attributes(cancelled_at: nil)

        subscription.cancelled_at_is_valid?
        expect(subscription.errors[:cancelled_at].present?).to eq(false)
      end

      it "returns error if invoices.empty?" do
        subscription.update_attributes(cancelled_at: Date.tomorrow)

        expect(subscription.invoices.empty?).to eq(true)

        subscription.cancelled_at_is_valid?

        expect(subscription.errors[:cancelled_at].present?).to eq(true)
      end

      it "returns error if cancelled_at < earliest_invoice_or_org_created_at" do
        subscription.update_attributes(cancelled_at: organization.created_at)

        invoice
        expect(subscription.invoices.empty?).to eq(false)

        subscription.cancelled_at_is_valid?

        expect(subscription.errors[:cancelled_at].present?).to eq(true)
      end
    end

    describe "#earliest_invoice_or_org_created_at" do
      it "returns the earliest invoice service_period_start if invoices are present" do
        invoice

        expect(subscription.send(:earliest_invoice_or_org_created_at)).to eq(invoice.service_period_start)
      end

      it "returns organization.created_at if invoices are not present" do
        expect(subscription.send(:earliest_invoice_or_org_created_at)).to eq(organization.created_at)
      end
    end
  end
end
