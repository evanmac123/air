class Admin::SubscriptionsController < AdminBaseController

  def create
    subscription = Subscription.new(subscription_params)

    if subscription.save
      flash[:success] = "Subscription created."
      redirect_to admin_organization_path(subscription.organization)
    else
      flash[:failure] = "Subscription could not be created due to #{subscription.errors.full_messages}."
      redirect_to :back
    end
  end

  def destroy
    @subscription = Subscription.find(params[:id])

    if @subscription.invoices.empty? && @subscription.destroy
      flash[:success] = "Subscription has been deleted."
    else
      flash[:failure] = "Cannot delete a subscription that has invoices.  It is receommended that you simply cancel the subscription. If you would liek to delete the subscription, please delete all invoices first."
    end

    redirect_to :back
  end

  def cancel
    @subscription = Subscription.find(params[:subscription_id])
    @subscription.assign_attributes(subscription_params)

    if @subscription.save
      ChartMogulService::Subscription.new(subscription: @subscription).cancel
      flash[:success] = "Subscription cancelled."
    else
      flash[:failure] = @subscription.errors[:cancelled_at][0]
    end

    redirect_to :back
  end

  private

    def subscription_params
      params.require(:subscription).permit(:subscription_plan_id, :organization_id, :cancelled_at)
    end
end
