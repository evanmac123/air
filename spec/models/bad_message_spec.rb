require 'spec_helper'

describe BadMessage do
  it { is_expected.to validate_presence_of(:received_at) }
end
