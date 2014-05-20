class ClientAdmin::BillingInformationsController < ClientAdminBaseController
  class CreditCard < Struct.new(:number, :expiration, :cvc, :zip)
    extend  ActiveModel::Naming
    include ActiveModel::Conversion

    def initialize(params={})
      params.keys.each do |key|
        send "#{key}=", params[key]
      end
    end

    def to_stripe_params
      {
        number:      normalized_number,
        exp_month:   exp_month,
        exp_year:    exp_year,
        cvc:         cvc,
        address_zip: zip
      }
    end

    def normalized_number
      @normalized_number ||= number.gsub(/\D/, '')
    end

    def normalized_expiration
      return @normalized_expiration if @normalized_expiration

      @normalized_expiration ||= expiration.gsub(/\D/, '')
      # Can't just do this with sprintf, it chokes on trying to interpret an 
      # empty string as a decimal number (%d)
      while @normalized_expiration.length < 4
        @normalized_expiration = '0' + @normalized_expiration
      end

      @normalized_expiration
    end

    def exp_month
      normalized_expiration[0,2]
    end

    def exp_year
      normalized_expiration[2,2]
    end

    def persisted?
      false
    end

    def self.model_name
      # no namespacing kthx
      ActiveModel::Name.new(CreditCard, nil, "credit_card")
    end
  end

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

    redirect_to :back
  end

  protected

  def user_description(user)
    "#{user.name} (#{user.email})"
  end
end
