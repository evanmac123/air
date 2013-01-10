require 'acceptance/acceptance_helper'

feature "Admin deletes a rule" do

  context 'Standard rule' do
    scenario "the rule is deleted, associated acts are nullified, \
              and a message is displayed on the list of the all-standard-rules page"  do

      rule = FactoryGirl.create :rule, demo: nil
      FactoryGirl.create :primary_value, rule: rule, value: 'drink more coffee'
      acts = FactoryGirl.create_list :act, 3, rule: rule

      visit admin_rules_path(as: an_admin)
      click_link 'Delete Rule'

      current_path.should == admin_rules_path
      page.should have_content "The 'drink more coffee' rule was deleted"

      acts.each { |act| act.reload.rule.should be_nil }
    end
  end

  context 'Demo rule' do
    scenario "the rule is deleted, associated acts are nullified, \
              and a message is displayed on the list of the all-rules-for-this-demo page"  do

      demo = FactoryGirl.create :demo, name: 'wwoz'

      rule = FactoryGirl.create :rule, demo: demo
      FactoryGirl.create :primary_value, rule: rule, value: 'drink more coffee'
      acts = FactoryGirl.create_list :act, 3, rule: rule

      visit admin_demo_rules_path(demo, as: an_admin)
      click_link 'Delete Rule'

      current_path.should == admin_demo_rules_path(demo)
      page.should have_content "The 'drink more coffee' rule was deleted"

      acts.each { |act| act.reload.rule.should be_nil }
    end
  end
end

