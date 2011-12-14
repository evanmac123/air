require 'spec_helper'

describe OutgoingSms do
  it { should belong_to :in_response_to }
end
