require 'spec_helper'

describe UserCreatorFeeder do
  before do
    Redis.new.flushdb
  end

  let (:key)     {"test_queue"}
  let (:lines)   {["Line 1", "Line 2", "Line 3"]} 
  let (:demo_id) {1}
  let (:schema)  {%w(foo bar baz)}
  let (:feeder)  {UserCreatorFeeder.new(key, demo_id, schema)}
  
  describe "#feed" do
    it "should feed lines from Redis to a UserCreatorFromCsv" do
      mock_user_creator = stub('UserCreatorFromCsv')
      mock_user_creator.stubs(:create_user).with(kind_of(String)).returns(true)
      UserCreatorFromCsv.stubs(:new).with(kind_of(Integer), kind_of(Enumerable)).returns(mock_user_creator)

      Redis.new.lpush(key, lines)

      feeder.feed

      line_order = sequence('line_order')
      lines.each {|line| mock_user_creator.should have_received(:create_user).with(line).in_sequence(line_order)}
    end

    it "should log errors to some queue somewhere"
  end

  describe "#done?" do
    it "should return true if the queue is empty" do
      Redis.new.llen(key).should be_zero
      feeder.done?.should be_true
    end

    it "should return false if the queue is not empty" do
      Redis.new.lpush(key, lines)
      feeder.done?.should be_false
    end
  end
end
