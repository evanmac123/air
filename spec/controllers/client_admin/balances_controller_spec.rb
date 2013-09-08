require 'spec_helper'

describe ClientAdmin::BalancesController do
  DUMMY_CHARGE_PARAMETERS = {id: "foobar"} 
  DUMMY_CHARGE = Stripe::Charge.new DUMMY_CHARGE_PARAMETERS

  DUMMY_STRIPE_TOKEN = 'tok_123456789'

  before do
    Stripe::Charge.stubs(:create).returns(DUMMY_CHARGE)
    
    @balance = FactoryGirl.create(:balance, amount: 2995)

    @client_admin = FactoryGirl.create(:client_admin, name: "John Doe", email: "jdoe@example.com")
    @client_admin.demo.update_attributes(name: "United Consolidated")
    sign_in_as @client_admin
  end

  def post_payment
    put "update", {id: @balance.id, stripeToken: DUMMY_STRIPE_TOKEN}
  end

  context "when the charge succeds" do
    before do
      post_payment
    end

    it "should send the correct charge information to Stripe" do
      Stripe::Charge.should have_received(:create).with({amount: @balance.amount, currency: 'usd', card: DUMMY_STRIPE_TOKEN, description: "John Doe <jdoe@example.com> - United Consolidated"})
    end

    it "should record a payment associated with the balance" do
      payment = @balance.reload.payment
      payment.should be_present
      payment.user_id.should == @client_admin.id

      payment.raw_stripe_charge.to_json.should == DUMMY_CHARGE.to_json
      payment.amount.should  == @balance.amount
    end

    it "should put some kind of response in the flash" do
      flash[:success].should == "Thank you! We've received your payment and your credit card will be charged $29.95."
    end

    it "should redirect to the new payment page" do
      response.should redirect_to(new_client_admin_payment_path)
    end
  end

  context "when the charge fails" do
    before do
      Stripe::Charge.stubs(:create).raises(Stripe::CardError.new("oh no mr bill", nil, nil))
      post_payment
    end

    it "should record no payment" do
      Payment.all.should be_empty
    end

    it "should put an error in the flash" do
      flash[:failure].should == "Sorry, something went wrong with the payment. Your card has not been charged. Please try again in a little bit, or contact support@hengage.com for help."
    end

    it "should redirect to the new payment page" do
      response.should redirect_to(new_client_admin_payment_path)
    end
  end
end
