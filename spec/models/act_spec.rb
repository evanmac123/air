require 'spec_helper'

describe Act do
  it { should belong_to(:user) }
  it { should belong_to(:rule) }
end

describe Act, ".parse" do
  context "when user has not been invited to the game" do
    it "tells them" do
      number = "+14155551212"
      User.find_by_phone_number(number).should be_nil

      reply = "I can't find your number in my records. Did you claim your account yet? If not, text your first initial and last name (if you are John Smith, text \"jsmith\")."      
      Act.parse(number, "hello?").should == reply
    end
  end

  context "when user is in the game" do
    let(:user) { Factory(:user, :phone_number => '+16175551212') }

    context "and asks for help" do
      it "helps them" do
        reply = 'Earn points, text: "went to gym", "ate fruit", "ate vegetables", "walked stairs", "ran outside", "walked outside" - provided you did those things, of course.'
        Act.parse(user, "help").should == reply
      end
    end

    context "and types a bad key" do
      it "prompts them to ask for help" do
        reply = "We didn't understand. Try: help"
        Act.parse(user, "wakka").should == reply
      end
    end

    context "and types a good key" do
      let(:key)        { Factory(:key) }
      let(:rule)       { Factory(:rule, :key => key) }
      let(:good_value) { rule; key.rules.first.value }

      context "with a bad value" do
        it "prompts them with a good value" do
          reply = "We understand #{key.name} but not bad value. Try: #{key.name} #{good_value}"
          Act.parse(user, "#{key.name} bad value").should == reply
        end
      end

      context "with a good value" do
        let(:good_sms) { "#{key.name} #{good_value}" }

        before do
          @result = Act.parse(user, good_sms)
        end

        it "replies with the rule's reply" do
          @result.should include(rule.reply)
        end

        it "creates an act" do
          Act.should be_exists(:user_id => user.id, :text => good_sms, :rule_id => rule.id)
        end

        it "updates users points" do
          user.reload.points.should == rule.points
        end
      end
    end
  end
end
