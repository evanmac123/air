require 'spec_helper'

describe BadMessage do
  it { should validate_presence_of(:phone_number) }
  it { should validate_presence_of(:received_at) }
end
