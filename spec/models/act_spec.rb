require 'spec_helper'

describe Act do
  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:referring_user) }
  it { is_expected.to belong_to(:demo) }
end
