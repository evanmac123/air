require 'spec_helper'

describe Admin::SubscriptionsController do
  let(:admin) { FactoryGirl.create(:site_admin) }
  let(:organization) { Organization.create(name: "Test") }
  let(:plan) { SubscriptionPlan.create(name: "Test Plan", interval_count: 1, interval_cd: 0) }

  let(:subscription) { Subscription.create(subscription_plan: plan, organization: organization) }

  let(:invoice) { subscription.invoices.create(
    amount_in_cents: 1000,
    service_period_start: Date.today,
    service_period_end: Date.today + 1.year
  ) }

  describe "POST create" do
    describe "valid subscription" do
      before do
        subject.expects(:subscription_params).returns({ subscription_plan_id: plan.id, organization_id: organization.id })

        sign_in_as(admin)
        # post :create, organization: { id: organization.id }
      end

      xit "saves subscription" do
        expect(Subscription.count).to eq(1)
      end

      xit "returns flash" do
        expect(flash[:success].present?).to eq(true)
      end

      xit "redirects to admin_organization_path" do
        expect(response).to redirect_to(admin_organization_path(organization))
      end
    end
  end

  describe "POST destroy" do

  end

  describe "POST cancel" do

  end
end
#
# class Admin::SubscriptionsController < AdminBaseController
#
#   def create
#     subscription = Subscription.new(subscription_params)
#
#     if subscription.save
#       flash[:success] = "Subscription created."
#       redirect_to admin_organization_path(subscription.organization)
#     else
#       flash[:failure] = "Subscription could not be created due to #{subscription.errors.full_messages}."
#       redirect_to :back
#     end
#   end
#
#   def destroy
#     @subscription = Subscription.find(params[:id])
#
#     if @subscription.invoices.empty? && @subscription.destroy
#       flash[:success] = "Subscription has been deleted."
#     else
#       flash[:failure] = "Cannot delete a subscription that has invoices.  It is receommended that you simply cancel the subscription. If you would liek to delete the subscription, please delete all invoices first."
#     end
#
#     redirect_to :back
#   end
#
#   def cancel
#     @subscription = Subscription.find(params[:subscription_id])
#     @subscription.assign_attributes(subscription_params)
#
#     if @subscription.save
#       ChartMogulService::Subscription.new(subscription: @subscription).cancel
#       flash[:success] = "Subscription cancelled."
#     else
#       flash[:failure] = @subscription.errors[:cancelled_at][0]
#     end
#
#     redirect_to :back
#   end
#
#   private
#
#     def subscription_params
#       params.require(:subscription).permit(:subscription_plan_id, :organization_id, :cancelled_at)
#     end
# end
