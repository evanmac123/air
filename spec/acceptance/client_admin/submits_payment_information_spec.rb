require 'acceptance/acceptance_helper'

feature 'Submits payment information' do
  DUMMY_CUSTOMER_TOKEN = "cus_foobar"
  DUMMY_CARD_TOKEN     = "card_quux"

  # The parameters for a CC that we're concerned with, formatted the way
  # Stripe expects to get them, or the way Stripe returns them, as is
  # appropriate.
  VALID_CC_NUMBER        = "4012345981398502"
  VALID_LAST_4           = VALID_CC_NUMBER[-4, 4]
  VALID_EXPIRATION       = "0219"
  VALID_EXPIRATION_MONTH = VALID_EXPIRATION[0,2]
  VALID_EXPIRATION_YEAR  = VALID_EXPIRATION[2,2]
  VALID_CVC              = "456"
  VALID_ZIP              = "01234"
  VALID_COMPANY          = "American Excess"

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
    expect(Stripe::Customer).to have_received(:create).with(
      card:  VALID_STRIPE_CARD_PARAMETERS, 
      email: @client_admin.email, 
      description: "#{@client_admin.name} (#{@client_admin.email})"
    )
  end

  def expect_no_call_to_stripe
    expect(Stripe::Customer).to have_received(:create).never
  end

  def stripe_raises_card_error(error_message)
    exception = Stripe::CardError.new(error_message, nil, nil)
    Stripe::Customer.stubs(:create).raises(exception)
  end

  before do
    # We could avoid all this nonsense if the Stripe library would let us just
    # do Stripe::Customer.new(stuff_we_actually_want) and have it work.

    @dummy_card      = mock("Stripe::Card")
    @dummy_card.stubs(:id).returns(DUMMY_CARD_TOKEN)
    @dummy_card.stubs(:exp_month).returns(VALID_EXPIRATION_MONTH)
    @dummy_card.stubs(:exp_year).returns(VALID_EXPIRATION_YEAR)
    @dummy_card.stubs(:last4).returns(VALID_LAST_4)
    @dummy_card.stubs(:type).returns(VALID_COMPANY)

    @dummy_card_list = [@dummy_card]

    @dummy_customer = mock("Stripe::Customer")
    @dummy_customer.stubs(:default_card).returns(DUMMY_CARD_TOKEN)
    @dummy_customer.stubs(:cards).returns(@dummy_card_list)
    @dummy_customer.stubs(:id).returns(DUMMY_CUSTOMER_TOKEN)

    Stripe::Customer.stubs(:create).returns(@dummy_customer)

    @client_admin = FactoryGirl.create(:client_admin, name: "Joey Bananas", email: "joey@example.com")
    visit client_admin_billing_information_path(as: @client_admin)
  end

  scenario 'that gets shipped off to Stripe', js: true do
    submit_valid_cc_entries
    expect_stripe_called_with_happy_path_parameters
  end

  scenario 'saving the expiration date, last 4, Stripe customer token, and Stripe card token in the database', js: true do
    submit_valid_cc_entries
    billing_information = @client_admin.billing_information

    expect(billing_information.expiration_month).to eq(VALID_EXPIRATION_MONTH)
    expect(billing_information.expiration_year).to  eq(VALID_EXPIRATION_YEAR)
    expect(billing_information.last_4).to           eq(VALID_LAST_4)
    expect(billing_information.issuer).to           eq(VALID_COMPANY)
    expect(billing_information.customer_token).to   eq(DUMMY_CUSTOMER_TOKEN)
    expect(billing_information.card_token).to       eq(DUMMY_CARD_TOKEN)
  end

  scenario "normalizes the card number", js: true do
    fill_in_valid_cc_entries
    fill_in number_field, with: "4012 3459-8139 8502"
    submit_card

    expect_stripe_called_with_happy_path_parameters
  end
  
  scenario "normalizes the month and year in a short format", js: true do
    fill_in_valid_cc_entries
    fill_in expiration_field, with: "219"
    submit_card

    expect_stripe_called_with_happy_path_parameters
  end

  scenario "normalizes the month and year in a long format", js: true do
    fill_in_valid_cc_entries
    fill_in expiration_field, with: "02/2019"
    submit_card

    expect_stripe_called_with_happy_path_parameters
  end

  scenario 'and triggers an email to us', js: true do
    submit_valid_cc_entries
    crank_dj_clear

    open_email(BILLING_INFORMATION_ENTERED_NOTIFICATION_ADDRESS)
    expect(current_email).to have_body_text("Joey Bananas (joey@example.com) submitted payment information to Stripe for the #{@client_admin.demo.name} (#{@client_admin.demo_id})")
  end

  scenario 'sees a link back to the tiles page', js: true do
    submit_valid_cc_entries

    expect(page).to have_content("Payment Successful!")
    expect(page).to have_link("Back to Manage", client_admin_tiles_path)
  end

  context 'when they enter bad information' do
    context 'that we can detect on our side' do
      scenario 'to wit, a missing CC#', js: true do
        fill_in_valid_cc_entries
        fill_in number_field, with: ''
        submit_card

        expect_no_call_to_stripe
        expect(page).to have_content("please enter a credit card number")
      end

      scenario 'to wit, a missing expiration', js: true do
        fill_in_valid_cc_entries
        fill_in expiration_field, with: ''
        submit_card

        expect_no_call_to_stripe
        expect(page).to have_content("please enter an expiration date")
      end

      scenario 'to wit, a missing CVC', js: true do
        fill_in_valid_cc_entries
        fill_in cvc_field, with: ''
        submit_card

        expect_no_call_to_stripe
        expect(page).to have_content("please enter the security code for this card")
      end

      scenario 'to wit, a missing ZIP', js: true do
        fill_in_valid_cc_entries
        fill_in zip_field, with: ''
        submit_card

        expect_no_call_to_stripe
        expect(page).to have_content("please enter the billing ZIP code for this card")
      end
    end

    context 'when stuff looks fine to us, but Stripe throws a card error' do
      it 'passes along the message from that error', js: true do
        stripe_raises_card_error "You did it wrong."
        submit_valid_cc_entries
        expect(page).to have_content "you did it wrong"
      end

      it 'formats multiple-sentence Stripe errors properly', js: true do
        stripe_raises_card_error "You did it wrong. Ask someone else to show you. Or give up."
        submit_valid_cc_entries
        expect(page).to have_content "you did it wrong. Ask someone else to show you. Or give up"
      end

      it "makes the errors a bit politer", js: true do
        stripe_raises_card_error "Your card was temporarily rejected. Try again in a little bit."
        submit_valid_cc_entries
        expect(page).to have_content "Please try again in a little bit"
      end
    end
  end
end
