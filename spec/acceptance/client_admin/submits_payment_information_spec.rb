require 'acceptance/acceptance_helper'

feature 'Submits payment information' do
  DUMMY_CUSTOMER_TOKEN = "cus_foobar"
  DUMMY_CARD_TOKEN     = "card_quux"

  # The parameters for a CC that we're concerned with, formatted the way
  # Stripe expects to get them.
  VALID_CC_NUMBER        = "4012345981398502"
  VALID_LAST_4           = VALID_CC_NUMBER[-4, 4]
  VALID_EXPIRATION       = "0219"
  VALID_EXPIRATION_MONTH = VALID_EXPIRATION[0,2]
  VALID_EXPIRATION_YEAR  = VALID_EXPIRATION[2,2]
  VALID_CVC              = "456"
  VALID_ZIP              = "01234"

  VALID_STRIPE_CARD_PARAMETERS  = {
    number:      VALID_CC_NUMBER, 
    exp_month:   VALID_EXPIRATION_MONTH, 
    exp_year:    VALID_EXPIRATION_YEAR, 
    cvc:         VALID_CVC, 
    address_zip: VALID_ZIP
  }

  def number_field
    "credit_card[number]"
  end

  def expiration_field
    "credit_card[expiration]"
  end

  def cvc_field
    "credit_card[cvc]"
  end

  def zip_field
    "credit_card[zip]"
  end

  def submit_card
    click_button "Purchase"
  end

  def fill_in_valid_cc_entries
    fill_in number_field,     with: VALID_CC_NUMBER
    fill_in expiration_field, with: VALID_EXPIRATION
    fill_in cvc_field,        with: VALID_CVC
    fill_in zip_field,        with: VALID_ZIP
  end

  def submit_valid_cc_entries
    fill_in_valid_cc_entries
    submit_card
  end

  def expect_stripe_called_with_happy_path_parameters
    Stripe::Customer.should have_received(:create).with(card: VALID_STRIPE_CARD_PARAMETERS, email: @client_admin.email, description: "#{@client_admin.name} (#{@client_admin.email})")
  end

  before do
    # We could avoid all this nonsense if the Stripe library would let us just
    # do Stripe::Customer.new(stuff_we_actually_want) and have it work.

    @dummy_card      = mock("Stripe::Card")
    @dummy_card.stubs(:id).returns(DUMMY_CARD_TOKEN)
    @dummy_card.stubs(:exp_month).returns(VALID_EXPIRATION_MONTH)
    @dummy_card.stubs(:exp_year).returns(VALID_EXPIRATION_YEAR)
    @dummy_card.stubs(:last4).returns(VALID_LAST_4)

    @dummy_card_list = [@dummy_card]

    @dummy_customer = mock("Stripe::Customer")
    @dummy_customer.stubs(:default_card).returns(DUMMY_CARD_TOKEN)
    @dummy_customer.stubs(:cards).returns(@dummy_card_list)
    @dummy_customer.stubs(:id).returns(DUMMY_CUSTOMER_TOKEN)

    Stripe::Customer.stubs(:create).returns(@dummy_customer)

    @client_admin = FactoryGirl.create(:client_admin)
    visit client_admin_billing_information_path(as: @client_admin)
  end

  scenario 'that gets shipped off to Stripe' do
    submit_valid_cc_entries
    expect_stripe_called_with_happy_path_parameters
  end

  scenario 'saving the expiration date, last 4, Stripe customer token, and Stripe card token in the database' do
    submit_valid_cc_entries
    billing_information = @client_admin.billing_information

    billing_information.expiration_month.should == VALID_EXPIRATION_MONTH
    billing_information.expiration_year.should  == VALID_EXPIRATION_YEAR
    billing_information.last_4.should           == VALID_LAST_4
    billing_information.customer_token.should   == DUMMY_CUSTOMER_TOKEN
    billing_information.card_token.should       == DUMMY_CARD_TOKEN
  end

  scenario "normalizes the card number" do
    fill_in_valid_cc_entries
    fill_in number_field, with: "4012 3459-8139 8502"
    submit_card

    expect_stripe_called_with_happy_path_parameters
  end
  
  scenario "normalizes the month and year" do
    fill_in_valid_cc_entries
    fill_in expiration_field, with: "219"
    submit_card

    expect_stripe_called_with_happy_path_parameters
  end

  scenario 'and triggers an email to us'

  context 'when they enter bad information' do
    it 'reprimands them gently'
  end
end
