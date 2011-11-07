require 'spec_helper'

describe TimedBonus do
  it {should belong_to(:user)}
  it {should belong_to(:demo)}
  it {should validate_presence_of(:expires_at)}
  it {should validate_presence_of(:points)}
  it {should validate_presence_of(:user_id)}
  it {should validate_presence_of(:demo_id)}
end
