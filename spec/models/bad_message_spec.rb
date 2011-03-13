require 'spec_helper'

describe BadMessage do
  it { should validate_presence_of(:phone_number) }
  it { should validate_presence_of(:received_at) }

  context "creation" do
    it "should create a thread for the message" do
      Factory(:bad_message).thread.should_not be_nil
    end

    it "should assign messages from the same number within the grouping threshold apart to the same thread" do
      number = '+18085551212'

      first = nil
      second = nil
      third = nil
      fourth = nil

      # Have to specify a time in range of what Postgres can live with.
      Timecop.freeze('2010-01-01 12:00:00') do
        first = Factory :bad_message, :phone_number => number

        Timecop.freeze(Time.now + BadMessage::GROUPING_TIMEOUT - 1.second) do
          second = Factory :bad_message, :phone_number => number

          Timecop.freeze(Time.now + BadMessage::GROUPING_TIMEOUT - 1.second) do
            third = Factory :bad_message, :phone_number => number 

            Timecop.freeze(Time.now + BadMessage::GROUPING_TIMEOUT + 1.second) do
              fourth = Factory :bad_message, :phone_number => number 
            end
          end
        end
      end

      first.thread.should_not be_nil
      fourth.thread.should_not be_nil

      first.thread.should == second.thread
      first.thread.should == third.thread
      first.thread.should_not == fourth.thread

      fourth.thread.should have(1).messages
    end
  end
end
