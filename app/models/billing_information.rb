class BillingInformation < ActiveRecord::Base
  belongs_to :user

  def self.build_from_stripe_response(stripe_customer)
    card = find_default_card(stripe_customer)

    self.new(
      expiration_month: card.exp_month,
      expiration_year:  card.exp_year,
      last_4:           card.last4,
      customer_token:   stripe_customer.id,
      card_token:       stripe_customer.default_card
    )
  end

  def self.find_default_card(stripe_customer)
    default_card_id = stripe_customer.default_card
    stripe_customer.cards.detect{|card| card.id == default_card_id}
  end
end
