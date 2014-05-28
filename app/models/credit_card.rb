# This class is probably a good place to remind people that just because
# a class is in app/models, it _doesn't_ necessarily have to inherit from
# ActiveRecord::Base. In this case we don't because, if there's a bigger
# liability than storing credit card numbers in our DB if we don't have to,
# I for one do not want to hear about it.
#
# Do not put this in the database or I will murder you. XOXO, Phil.

class CreditCard < Struct.new(:number, :expiration, :cvc, :zip)
  extend  ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  validates_presence_of :number,     message: 'please enter a credit card number'
  validates_presence_of :expiration, message: 'please enter an expiration date'
  validates_presence_of :cvc,        message: 'please enter the security code for this card'
  validates_presence_of :zip,        message: 'please enter the billing ZIP code for this card'

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
    normalized_expiration[-2,2]
  end

  def persisted?
    false
  end

  def self.model_name
    ActiveModel::Name.new(CreditCard)
  end
end
