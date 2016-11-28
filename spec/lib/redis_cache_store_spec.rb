require "spec_helper"

describe Redis do
  it "Rails.cache adds to Redis under cache namespace and Rails.cache.clear only clears cache namespace" do
      Rails.cache.write("test", expires_in: 5.days)
      User.rdb['test'].set(1)

      expect($redis.keys.length).to eq(2)

      Rails.cache.clear

      expect($redis.keys.length).to eq(1)
  end
end
