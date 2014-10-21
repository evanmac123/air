class ClientAdmin::BalancesController < ClientAdminBaseController
  def update
    # SEC: the following is an insecure direct object reference (IDOR), since
    # we don't validate if the user can actually see this balance. But:
    #
    # * this particular hole only lets you pay someone else's tab, and
    # * this is only linked to (via the payment page) for a client admin in a 
    #   board with outstanding balances, of which there's exactly 1 in 
    #   production, and it's an antique
    # * this has been superseded by the new BillingInformation flow
    #
    # As such, odds are that we'll cut this controller soon, and this is not
    # doing much harm in the meantime.
    balance = Balance.find(params[:id])
    charge_description = "#{current_user.name} <#{current_user.email}> - #{current_user.demo.name}"

    begin
      charge = Stripe::Charge.create({
        amount:      balance.amount,
        card:        params[:stripeToken],
        currency:    'usd',
        description: charge_description
      })

      payment = Payment.create!(user: current_user, balance: balance, amount: balance.amount, raw_stripe_charge: charge)

      flash[:success] = "Thank you! We've received your payment and your credit card will be charged #{balance.pretty_amount}."
    rescue Stripe::CardError => e
      flash[:failure] = "Sorry, something went wrong with the payment. Your card has not been charged. Please try again in a little bit, or contact support@air.bo for help."
    end

    redirect_to new_client_admin_payment_path
  end
end
