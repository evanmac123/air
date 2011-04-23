require 'spec_helper'

describe Rule do
  subject { Factory(:rule) }

  it { should have_many(:acts) }

  it { should validate_presence_of(:value) }
  it { should validate_uniqueness_of(:value) }

  describe "#to_s" do
    before(:each) do
      @rule = Factory :rule, :value => 'engendered healthificity'
    end

    context "when no description is set" do
      it "should be made from the name of the key and the value of the rule" do
        @rule.to_s.should == "engendered healthificity"
      end
    end

    context "when a description is set" do
      it "should use that" do
        @rule.description = "Made health"
        @rule.to_s.should == "Made health"
      end
    end
  end

  describe "before save" do
    it "should normalize the value" do
      rule = Factory.build :rule, :value => '   FoO    BaR '
      rule.save!
      rule.value.should == 'foo bar'
    end
  end

  describe Rule, ".find_and_record_rule_suggestion" do
    before(:each) do
      [
        'ate banana',
        'ate kitten',
        'ate an entire pizza',
        'ate Sheboygan',
        'worked out',
        'drank beer',
        'drank whiskey',
        'went for a walk',
        'took a walk',
        'walked outside'
      ].each {|value| Factory :rule, :value => value}

      @user = Factory :user
    end

    context "when nothing matches well" do
      it "should return nil" do
        Rule.send(:find_and_record_rule_suggestion, 'played guitar', @user).should be_nil
      end
    end

    context "when one thing matches well" do
      before(:each) do
        @result = Rule.send(:find_and_record_rule_suggestion, 'pet kitten', @user)
      end

      it "should return an appropriate phrase" do
        @result.should == '(1) "ate kitten"'
      end

      it "should set the user's last suggested rules" do
        @user.reload.last_suggested_items.should == Rule.find_by_value('ate kitten').id.to_s
      end
    end

    context "when more than one thing matches well" do
      before(:each) do
        @result = Rule.send(:find_and_record_rule_suggestion, 'ate raisins', @user)
      end

      it "should return an appropriate phrase" do
        @result.should == '(1) "ate an entire pizza" or (2) "ate banana" or (3) "ate kitten"'
      end

      it "should set the user's last suggested rules" do
        expected_indices = [
          'ate an entire pizza', 
          'ate banana', 
          'ate kitten'
        ].map{|value| Rule.find_by_value(value)}.map(&:id)
        
        @user.reload.last_suggested_items.should == expected_indices.map(&:to_s).join('|')
      end
    end

    it "should ignore rules that are marked as not \"suggestible\"" do
      rule = Rule.find_by_value('ate an entire pizza')
      rule.suggestible = false
      rule.save!

      Rule.send(:find_and_record_rule_suggestion, 'ate raisins', @user).should_not include('ate an entire pizza')
    end
  end
end
