class ClientAdmin::BalancesController < ClientAdminBaseController
  def update
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
      flash[:failure] = "Sorry, something went wrong with the payment. Your card has not been charged. Please try again in a little bit, or contact support@hengage.com for help."
    end

    redirect_to new_client_admin_payment_path
  end
end
