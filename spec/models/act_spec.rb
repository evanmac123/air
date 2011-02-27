require 'spec_helper'

describe Act do
  it { should belong_to(:user) }
  it { should belong_to(:rule) }
end

describe Act, ".parse" do
  context "when user has not been invited to the game" do
    it "tells them" do
      reply = "You haven't been invited to the game."
      Act.parse(nil, "hello?").should == reply
    end
  end

  context "when user is in the game" do
    let(:user) { Factory(:user) }

    context "and asks for help" do
      it "helps them" do
        reply = "Score points by texting this number your latest lifestyle act. Examples: ate a banana, smoked a cigarette, played basketball"
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
          @result.should == rule.reply
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
