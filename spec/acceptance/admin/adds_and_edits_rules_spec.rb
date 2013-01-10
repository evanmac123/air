require 'acceptance/acceptance_helper'

feature 'Admin adds and edits rules' do
  def expect_rule_rows(rule_or_hash)
    primary_value, secondary_values = (rule_or_hash.respond_to?(:primary_value)) ?
      [rule_or_hash.primary_value.value, rule_or_hash.secondary_values.map(&:value)] :
      [rule_or_hash['primary_value'], rule_or_hash['secondary_values'].split(',')]

    primary_value_cell = page.find(:css, 'td', :text => primary_value)
    primary_value_cell.should_not be_nil, "Found no rule row for \"#{primary_value}\""

    main_rule_row = primary_value_cell.find(:xpath, '..')
    cell_path = main_rule_row.path + "/td"

    %w(points reply description alltime_limit referral_points suggestible).each do |field_name|
      expected_value = rule_or_hash[field_name].to_s
      page.find(:xpath, cell_path, :text => expected_value).should_not be_nil, "Found no cell containing #{field_name} (expected value \"#{expected_value}\")"
    end

    secondary_values_cell_path = main_rule_row.path + "/following-sibling::tr/td"
    secondary_values.each do |secondary_value|
      page.find(:xpath, secondary_values_cell_path, :text => secondary_value).should_not be_nil, "Didn't find secondary value \"#{secondary_value}\""
    end
  end

  context "in the current demo" do
    before(:each) do
      @demo = FactoryGirl.create(:demo)
    end

    context "with existing rules" do
      before(:each) do
        @banana_rule = FactoryGirl.create(:rule, points: 12, reply: 'banana', description: 'I ate a banana', alltime_limit: 15, referral_points: 10, suggestible: true, demo: @demo)
        @kitten_rule = FactoryGirl.create(:rule, points: 6, reply: 'kitten', description: 'I ate a kitten', alltime_limit: 4, referral_points: 5, suggestible: true, demo: @demo)

        FactoryGirl.create(:rule_value, rule: @banana_rule, value: 'ate banana', is_primary: true)
        FactoryGirl.create(:rule_value, rule: @banana_rule, value: 'bananaed up', is_primary: false)
        FactoryGirl.create(:rule_value, rule: @banana_rule, value: 'got banana-ey', is_primary: false)

        FactoryGirl.create(:rule_value, rule: @kitten_rule, value: 'ate kitten', is_primary: true)
        FactoryGirl.create(:rule_value, rule: @kitten_rule, value: 'ate kitty', is_primary: false)
        FactoryGirl.create(:rule_value, rule: @kitten_rule, value: 'ate kittycat', is_primary: false)
      end

      scenario 'and sees existing rules' do
        visit admin_demo_rules_path(@demo, as: an_admin)
        [@banana_rule, @kitten_rule].each {|rule| expect_rule_rows(rule)}
      end

      scenario 'and edits all rule values' do
        visit edit_admin_rule_path(@banana_rule, as: an_admin)
        fill_in "rule[secondary_values][0]", :with => 'consumed banana'
        fill_in "rule[secondary_values][1]", :with => 'ate me a banana'
        click_button "Update Rule"

        should_be_on admin_demo_rules_path(@demo)
        expect_rule_rows(
          'primary_value' => 'ate banana',
          'secondary_values' => 'ate me a banana,consumed banana',
          'points' => 12,
          'reply' => 'banana',
          'description' => 'I ate a banana',
          'alltime_limit' => 15,
          'referral_points' => 10,
          'suggestible' => true
        )
      end

      scenario 'and edits some but not all rule values' do
        visit edit_admin_rule_path(@banana_rule, as: an_admin)
        fill_in "rule[secondary_values][1]", :with => 'ate me a banana'
        click_button "Update Rule"

        should_be_on admin_demo_rules_path(@demo)
        expect_rule_rows(
          'primary_value' => 'ate banana',
          'secondary_values' => 'ate me a banana,bananaed up',
          'points' => 12,
          'reply' => 'banana',
          'description' => 'I ate a banana',
          'alltime_limit' => 15,
          'referral_points' => 10,
          'suggestible' => true
        )
      end

      scenario 'and deletes a secondary rule value by blanking it out' do
        visit edit_admin_rule_path(@banana_rule, as: an_admin)
        fill_in "rule[secondary_values][1]", :with => 'ate me a banana'
        click_button "Update Rule"

        should_be_on admin_demo_rules_path(@demo)
        expect_rule_rows(
          'primary_value' => 'ate banana',
          'secondary_values' => 'bananaed up',
          'points' => 12,
          'reply' => 'banana',
          'description' => 'I ate a banana',
          'alltime_limit' => 15,
          'referral_points' => 10,
          'suggestible' => true
        )   
      end

      scenario 'and tries to delete the primary rule value by blanking it out' do
        visit edit_admin_rule_path(@banana_rule, as: an_admin)
        fill_in "rule[primary_value]", :with => ''
        click_button "Update Rule"

        should_be_on edit_admin_rule_path(@banana_rule)
        expect_content "You can't blank out the primary value of a rule"
      end

      scenario 'and edits the properties of a rule' do
        visit edit_admin_rule_path(@banana_rule, as: an_admin)
        fill_in "Primary value", :with => 'ate bananafruit'
        fill_in 'Points', :with => 100
        fill_in 'Reply', :with => '100 points! Toast is the God Food!'
        fill_in 'Description', :with => 'Made the God Food'
        fill_in 'Alltime limit', :with => '1'
        fill_in 'Referral points', :with => '18'
        uncheck 'Suggestible'
        click_button "Update Rule"

        should_be_on admin_demo_rules_path(@demo)
        expect_rule_rows(
          'primary_value' => 'ate bananafruit',
          'secondary_values' => 'bananaed up,got banana-ey',
          'points' => 100,
          'reply' => '100 points! Toast is the God Food!',
          'description' => 'Made the God Food',
          'alltime_limit' => 1,
          'referral_points' => 18,
          'suggestible' => false
        )
      end

      scenario "trying to add a rule with a duplicate rule value gives a sensible error instead of blowing up" do
        visit new_admin_demo_rule_path(@demo, as: an_admin)
        fill_in "Primary value", :with => 'ate banana'
        fill_in "Points", :with => 55
        fill_in "Reply", :with => '55 points for you, bucko.'
        fill_in "Description", :with => "I ate a big ol banana"
        click_button "Create Rule"

        should_be_on admin_demo_rules_path(@demo)
        expect_content 'Problem with primary value: Value must be unique within its demo'

        visit new_admin_demo_rule_path(@demo, as: an_admin)
        fill_in "Primary value", :with => 'konsumed kat'
        fill_in "Points", :with => 55
        fill_in "Reply", :with => '55 points for you, bucko.'
        fill_in "Description", :with => "I ate a kittykat."
        fill_in "rule[secondary_values][0]", :with => 'ate kitten'
        click_button "Create Rule"

        should_be_on admin_demo_rules_path(@demo)
        expect_content 'Problem with secondary value ate kitten: Value must be unique within its demo'
      end
 
      scenario "cancel link from rule edit page goes to the right place" do
        visit edit_admin_rule_path(@banana_rule, as: an_admin)
        click_link "Cancel"
        should_be_on admin_demo_rules_path(@demo)
      end
    end

    scenario "can add a new rule" do
      visit new_admin_demo_rule_path(@demo, as: an_admin)
      fill_in "Primary value", :with => 'ate oatmeal'
      fill_in "Points", :with => 55
      fill_in "Reply", :with => '55 points for you, bucko.'
      fill_in "Description", :with => "I ate a big ol bowl of oatmeal"
      fill_in "Alltime limit", :with => '5'
      fill_in "Referral points", :with => "19"
      uncheck "Suggestible"
      fill_in "rule[secondary_values][0]", :with => 'ate some oatmeal'
      click_button "Create Rule"

      should_be_on admin_demo_rules_path(@demo)
      expect_rule_rows(
        'primary_value' => 'ate oatmeal',
        'secondary_values' => 'ate some oatmeal',
        'points' => 55,
        'reply' => '55 points for you, bucko',
        'description' => 'I ate a big ol bowl of oatmeal',
        'alltime_limit' => 5,
        'referral_points' => 19,
        'suggestible' => false
      )
    end

    scenario "gets a warning if they create a rule that matches an SMS slug in the demo" do
      conflicting_user = FactoryGirl.create(:user, demo: @demo)
      visit new_admin_demo_rule_path(@demo, as: an_admin)
      fill_in "Primary value", :with => conflicting_user.sms_slug
      fill_in "Points", :with => 55
      fill_in "Reply", :with => '55 points for you, bucko.'
      fill_in "Description", :with => "I ate a big ol bowl of oatmeal"
      click_button "Create Rule"

      expect_content "Warning: rule value #{conflicting_user.sms_slug} conflicts with username"
    end
  end

  context "in the standard playbook" do
    before(:each) do
      @jogging_rule = FactoryGirl.create(:rule, points: 18, reply: 'jogging', description: 'I went jogging', alltime_limit: 666, referral_points: 44, suggestible: true, demo: nil)
      @weights_rule = FactoryGirl.create(:rule, points: 30, reply: 'weights', description: 'I lifted weights', alltime_limit: 14, referral_points: 79, suggestible: true, demo: nil)
      FactoryGirl.create(:rule_value, rule: @jogging_rule, value: 'went jogging', is_primary: true)
      FactoryGirl.create(:rule_value, rule: @jogging_rule, value: 'did jogging', is_primary: false)
      FactoryGirl.create(:rule_value, rule: @jogging_rule, value: 'went for a jog', is_primary: false)
      FactoryGirl.create(:rule_value, rule: @weights_rule, value: 'lifted weights', is_primary: true)
    end

    scenario "admin sees standard playbook rules" do
      visit admin_rules_path(as: an_admin)
      [@jogging_rule, @weights_rule].each {|rule| expect_rule_rows(rule)}
    end

    scenario "admin adds standard playbook rule" do
      visit new_admin_rule_path(as: an_admin)
      fill_in "Primary value", :with => 'ate oatmeal'
      fill_in "Points", :with => 55
      fill_in "Reply", :with => '55 points for you, bucko.'
      fill_in "Description", :with => "I ate a big ol bowl of oatmeal"
      fill_in "Alltime limit", :with => '5'
      fill_in "Referral points", :with => "19"
      uncheck "Suggestible"
      fill_in "rule[secondary_values][0]", :with => 'ate some oatmeal'
      click_button "Create Rule"

      should_be_on admin_rules_path
      expect_rule_rows(
        'primary_value' => 'ate oatmeal',
        'secondary_values' => 'ate some oatmeal',
        'points' => 55,
        'reply' => '55 points for you, bucko',
        'description' => 'I ate a big ol bowl of oatmeal',
        'alltime_limit' => 5,
        'referral_points' => 19,
        'suggestible' => false
      )    
    end

    scenario "admin edits standard playbook rule" do
      visit edit_admin_rule_path(@jogging_rule, as: an_admin)
      fill_in "Primary value", :with => 'ate bananafruit'
      fill_in "rule[secondary_values][0]", :with => 'bananaed up'
      fill_in "rule[secondary_values][1]", :with => 'got banana-ey'
      fill_in 'Points', :with => 100
      fill_in 'Reply', :with => '100 points! Toast is the God Food!'
      fill_in 'Description', :with => 'Made the God Food'
      fill_in 'Alltime limit', :with => '1'
      fill_in 'Referral points', :with => '18'
      uncheck 'Suggestible'
      click_button "Update Rule"

      should_be_on admin_rules_path
      expect_rule_rows(
        'primary_value' => 'ate bananafruit',
        'secondary_values' => 'bananaed up,got banana-ey',
        'points' => 100,
        'reply' => '100 points! Toast is the God Food!',
        'description' => 'Made the God Food',
        'alltime_limit' => 1,
        'referral_points' => 18,
        'suggestible' => false
      )
    end

    scenario "cancel link from standard playbook rule edit page goes to the right place" do
      visit edit_admin_rule_path(@jogging_rule, as: an_admin)
      click_link "Cancel"
      should_be_on admin_rules_path
    end
  end

  scenario '"smart" punctuation gets tranasliterated into normal happy ASCII characters' do
    visit new_admin_rule_path(as: an_admin)

    # This reads: I added this with “smart punctuation”—can you tell?
    fill_in "Primary value", :with => %{I added this with \u201csmart punctuation\u201d\u2014can you tell?}

    fill_in "Points", :with => 55
    fill_in "Reply", :with => "55 points for you, bucko."

    # And this reads: “Smart” punctuation is a scourge—is it not?
    fill_in "Description", :with => %{\u201cSmart\u201d punctuation is a scourge\u2014is it not?}
    click_button "Create Rule"

    should_be_on admin_rules_path
    expect_rule_rows(
      'primary_value' => 'i added this with "smart punctuation"-can you tell?',
      'secondary_values' => '',
      'points' => 55,
      'reply' => "55 points for you, bucko.",
      'description' => '"Smart" punctuation is a scourge-is it not?'
    )
  end
end
