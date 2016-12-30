require 'spec_helper'

describe OutgoingSms do
  it { is_expected.to belong_to :mate }
end
