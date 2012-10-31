require 'spec_helper'

describe Report::Activity do

  describe '#new' do
    let!(:demo) { FactoryGirl.create :demo, id: 1, name: 'RobertJohnsonDemo' }

    it 'creates a valid object if associated demo exists' do
      lambda { Report::Activity.new(1) }.should_not raise_error
    end

    it 'raises an exception if associated demo does not exist' do
      lambda { Report::Activity.new(2) }.should raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe '#send_email' do
    # The primary focus of this test is the CSV data, although it does test the other parameters (as does 'spec/mailers/mailer_spec.rb')
    it 'sends an activities report containing the correct CSV data' do
      demo = FactoryGirl.create :demo, name: 'MuddyWaters'

      boston =   FactoryGirl.create :location, demo: demo, name: 'Boston'
      new_york = FactoryGirl.create :location, demo: demo, name: 'New York'
      philly =   FactoryGirl.create :location, demo: demo, name: 'Philly'

      curly = FactoryGirl.create :user, :claimed, id: 1, demo: demo, location: boston
      larry = FactoryGirl.create :user, :claimed, id: 2, demo: demo, location: new_york
      moe   = FactoryGirl.create :user, :claimed, id: 3, demo: demo, location: philly
      # This user does not have a location => no value between ','s in the csv file
      shemp = FactoryGirl.create :user, :claimed, id: 4, demo: demo

      # Make sure the rule's 'primary_value' appears in the csv file, not its 'description'
      rule1 = FactoryGirl.create :rule, demo: demo, description: 'Description for rule # 1'
      rule2 = FactoryGirl.create :rule, demo: demo, description: 'Description for rule # 2'
      rule3 = FactoryGirl.create :rule, demo: demo, description: 'Description for rule # 3'
      rule4 = FactoryGirl.create :rule, demo: demo, description: 'Description for rule # 4'
      rule5 = FactoryGirl.create :rule, demo: demo, description: 'Description for rule # 5'
      rule6 = FactoryGirl.create :rule, demo: demo, description: 'Description for rule # 6'

      rules = [rule1, rule2, rule3, rule4, rule5, rule6]

      rules.each_with_index do |rule, i|
        # Only the 'primary_value' should appear in the csv file
        FactoryGirl.create :rule_value,    rule: rule, value: "Secondary value for rule_#{i + 1}"
        FactoryGirl.create :primary_value, rule: rule, value: "Primary value for rule_#{i + 1}"
      end

      users = [curly, larry, moe, shemp]
      # These non-rule-based acts should not appear in the csv file
      users.each { |user| FactoryGirl.create :act, user: user, demo: demo, text: "#{user.name} joined the game" }

      FactoryGirl.create :act, demo: demo, user: curly, rule: rule1, text: rule1.description, created_at: '2012-01-01'
      FactoryGirl.create :act, demo: demo, user: curly, rule: rule2, text: rule2.description, created_at: '2012-01-02'
      FactoryGirl.create :act, demo: demo, user: curly, rule: rule3, text: rule3.description, created_at: '2012-01-03'

      FactoryGirl.create :act, demo: demo, user: larry, rule: rule4, text: rule4.description, created_at: '2012-02-01'
      FactoryGirl.create :act, demo: demo, user: larry, rule: rule5, text: rule5.description, created_at: '2012-02-02'
      FactoryGirl.create :act, demo: demo, user: larry, rule: rule6, text: rule6.description, created_at: '2012-02-03'

      FactoryGirl.create :act, demo: demo, user: moe, rule: rule2, text: rule2.description, created_at: '2012-03-01'
      FactoryGirl.create :act, demo: demo, user: moe, rule: rule3, text: rule3.description, created_at: '2012-03-02'
      FactoryGirl.create :act, demo: demo, user: moe, rule: rule4, text: rule4.description, created_at: '2012-03-03'
      FactoryGirl.create :act, demo: demo, user: moe, rule: rule5, text: rule5.description, created_at: '2012-03-04'

      FactoryGirl.create :act, demo: demo, user: shemp, rule: rule1, text: rule1.description, created_at: '2012-04-01'
      FactoryGirl.create :act, demo: demo, user: shemp, rule: rule3, text: rule3.description, created_at: '2012-04-02'
      FactoryGirl.create :act, demo: demo, user: shemp, rule: rule5, text: rule5.description, created_at: '2012-04-03'

      # Create legitimate entities that should not show up in the csv file (to make sure we grab only the right stuff)
      demo_x = FactoryGirl.create :demo, name: 'xxx'
      user_x = FactoryGirl.create :user, :claimed, demo: demo_x
      rule_x = FactoryGirl.create :rule, demo: demo_x
      FactoryGirl.create :primary_value, rule: rule_x
      FactoryGirl.create :act, demo: demo_x, user: user_x, rule: rule_x

      expected_csv = <<CSV
id,location,rule,date
1,Boston,primary value for rule_1,01-01-2012
1,Boston,primary value for rule_2,01-02-2012
1,Boston,primary value for rule_3,01-03-2012
2,New York,primary value for rule_4,02-01-2012
2,New York,primary value for rule_5,02-02-2012
2,New York,primary value for rule_6,02-03-2012
3,Philly,primary value for rule_2,03-01-2012
3,Philly,primary value for rule_3,03-02-2012
3,Philly,primary value for rule_4,03-03-2012
3,Philly,primary value for rule_5,03-04-2012
4,,primary value for rule_1,04-01-2012
4,,primary value for rule_3,04-02-2012
4,,primary value for rule_5,04-03-2012
CSV

      Timecop.freeze(Time.parse("2011-05-01 13:00:00"))
      mailer = stub 'mailer', :deliver => nil
      Mailer.stubs :activity_report => mailer

      Report::Activity.new(demo.id).send_email('muddy@waters.com')

      Mailer.should have_received(:activity_report).with(expected_csv.strip, 'MuddyWaters', '2011-05-01 13:00:00 -0400', 'muddy@waters.com')
    end
  end
end
