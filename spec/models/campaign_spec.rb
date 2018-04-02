require 'spec_helper'

describe Campaign do
  it { is_expected.to belong_to :demo }
  it { is_expected.to have_many :tiles }
  it { is_expected.to validate_presence_of :name }
end
