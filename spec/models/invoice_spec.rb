require 'rails_helper'

RSpec.describe Invoice, :type => :model do
  it { is_expected.to validate_presence_of(:subscription) }
  it { is_expected.to validate_presence_of(:amount_in_cents) }
  it { is_expected.to validate_presence_of(:service_period_start) }
  it { is_expected.to validate_presence_of(:service_period_end) }
  it { is_expected.to validate_presence_of(:type_cd) }
  it { is_expected.to belong_to(:subscription) }
  it { is_expected.to have_many(:invoice_transactions) }
end
