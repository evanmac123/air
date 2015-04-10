require 'spec_helper'

describe BulkLoad::UserCreatorFeeder do
  before do
    Redis.new.flushdb
  end

  let (:object_name)     {"test_key"}
  let (:lines)           {["Line 1", "Line 2", "Line 3"]} 
  let (:demo_id)         {1}
  let (:schema)          {%w(foo bar baz)}
  let (:unique_id_field) {:email}
  let (:unique_id_index) {0}
  let (:feeder)          {BulkLoad::UserCreatorFeeder.new(object_name, demo_id, schema, unique_id_field, unique_id_index)}

  before do
    # Pretend the chopper is done
    Redis.new.set(feeder.redis_all_lines_chopped_key, "done")
  end

  describe "#feed" do
    it "should feed lines from Redis to a UserCreatorFromCsv" do
      mock_user_creator = stub('BulkLoad::UserCreatorFromCsv')
      mock_user_creator.stubs(:create_user).with(kind_of(String)).returns(stub("User", "invalid?" => false))
      BulkLoad::UserCreatorFromCsv.stubs(:new).returns(mock_user_creator)

      Redis.new.lpush(feeder.redis_load_queue_key, lines)

      feeder.feed

      line_order = sequence('line_order')
      lines.each {|line| mock_user_creator.should have_received(:create_user).with(line).in_sequence(line_order)}
    end

    it "should log errors to some queue somewhere" do
      existing_user = FactoryGirl.create(:user)
      demo_id = existing_user.demo.id
      email = existing_user.email
      email.should be_present

      schema = %w(name email)

      User.any_instance.stubs(:invalid?).returns(true)
      ActiveModel::Errors.any_instance.stubs(:full_messages).returns(["Error message 1"], ["Error message 2"])

      Redis.new.lpush(feeder.redis_load_queue_key, [
        CSV.generate_line(["John Smith","jsmith@example.com"]),
        CSV.generate_line(["Joe Blow", existing_user.email])
      ])

      feeder = BulkLoad::UserCreatorFeeder.new(object_name, demo_id, schema, unique_id_field, unique_id_index)
      feeder.feed

      Redis.new.llen(feeder.redis_failed_load_queue_key).should == 2
      Redis.new.rpop(feeder.redis_failed_load_queue_key).should == "Line 1: Error message 1"
      Redis.new.rpop(feeder.redis_failed_load_queue_key).should == "Line 2: Error message 2"
    end
  end

  describe "#done?" do
    it "should check the flag that the chopper is meant to set, as well as the length of the queue" do
      # queue empty but not signalled done yet from the chopper
      Redis.new.del(feeder.redis_all_lines_chopped_key)
      feeder.should_not be_done

      # queue not empty and no signal from the chopper
      3.times {Redis.new.lpush(feeder.redis_load_queue_key, "hey")}
      feeder.should_not be_done

      # chopper signals done, but we still have to work off some of the queue
      Redis.new.set(feeder.redis_all_lines_chopped_key, "done")
      feeder.should_not be_done

      # chopper signals done and we've worked through the entire queue, we're done
      Redis.new.del(feeder.redis_load_queue_key)
      feeder.should be_done
    end
  end
end
