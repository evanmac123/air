class ClientAdmin::BillingInformationsController < ClientAdminBaseController
  def show
    @credit_card = CreditCard.new
  end

  def create
    @credit_card = CreditCard.new(params[:credit_card])

    stripe_response = Stripe::Customer.create(
      email:       current_user.email, 
      description: user_description(current_user),
      card:        @credit_card.to_stripe_params
    )

    current_user.billing_information = BillingInformation.build_from_stripe_response(stripe_response)
    current_user.billing_information.save!

    notify_us_of_new_billing_information(current_user)
    redirect_to :back
  end

  protected

  def user_description(user)
    "#{user.name} (#{user.email})"
  end

  def notify_us_of_new_billing_information(user)
    BillingNotificationMailer.delay_mail(:notify, user.id, user.demo_id)
  end
end
