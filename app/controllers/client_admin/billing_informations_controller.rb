class ClientAdmin::BillingInformationsController < ClientAdminBaseController
  def show
    if current_user.billing_information.present?
      render_billing_information
    else
      render_billing_information_form
    end
  end

  def create
    @credit_card = CreditCard.new(whitelisted_params[:credit_card])
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

  def whitelisted_params
    params.permit(credit_card: [:number, :expiration, :cvc, :zip])
  end

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
    # Downcase the first letter and ditch the period.
    #
    # Note that we can't just do message.downcase because sometimes the error
    # is multiple sentences--we just wanna downcase the very first letter, so
    # it then fits into our error schema "Sorry, something went wrong: [something]"
   
    message = stripe_error.message.clone
    message[0] = message[0].downcase

    message.
      gsub(/Try again in a little bit/, 'Please try again in a little bit').
      gsub(/\.$/, '')
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

  def render_billing_information
    @billing_information = current_user.billing_information
    render :billing_information_exists
  end

  def render_billing_information_form
    @credit_card = CreditCard.new
    render :show
  end
end
