require 'spec_helper'

describe Suggestion do
  it {is_expected.to belong_to(:user)}
  it {is_expected.to validate_presence_of(:user_id)}
end
