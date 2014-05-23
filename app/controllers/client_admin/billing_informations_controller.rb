class ClientAdmin::BillingInformationsController < ClientAdminBaseController
  def show
    @credit_card = CreditCard.new
  end

  def create
    @credit_card = CreditCard.new(params[:credit_card])
    (failure_path and return) unless @credit_card.valid?

    begin
      stripe_response = post_billing_information_to_stripe
    rescue Stripe::CardError => stripe_error
      failure_path(stripe_error)
      return
    end

    save_billing_information(stripe_response)
    notify_us_of_new_billing_information(current_user)

    render :billing_successful
  end

  protected

  def failure_path(stripe_error = nil)
    errors = credit_card_errors
    if stripe_error
      errors << normalize_stripe_error_message(stripe_error)
    end

    flash.now[:failure] = "Sorry, we weren't able to process your credit card: " + errors.join(', ') + '.'
    render :show
  end

  def user_description(user)
    "#{user.name} (#{user.email})"
  end

  def notify_us_of_new_billing_information(user)
    BillingNotificationMailer.delay_mail(:notify, user.id, user.demo_id)
  end

  def credit_card_errors
    @credit_card.errors.messages.values
  end

  def normalize_stripe_error_message(stripe_error)
    # Stripe's typical style is "You did it wrong."
    # Downcase and ditch the period.
    stripe_error.message.downcase.gsub(/\.$/, '')
  end

  def post_billing_information_to_stripe
    Stripe::Customer.create(
      email:       current_user.email, 
      description: user_description(current_user),
      card:        @credit_card.to_stripe_params
    )
  end

  def save_billing_information(stripe_response)
    current_user.billing_information = BillingInformation.build_from_stripe_response(stripe_response)
    current_user.billing_information.save!
  end
end
