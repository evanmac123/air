require 'rails_helper'

RSpec.describe InvoiceTransaction, :type => :model do
  it { is_expected.to validate_presence_of(:type_cd) }
  it { is_expected.to belong_to(:invoice) }
end
