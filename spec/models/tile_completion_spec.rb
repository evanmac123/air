require 'spec_helper'

describe TileCompletion do
  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:tile) }
end
