require 'acceptance/acceptance_helper'

feature "Admin segmentation" do
  def create_characteristics_and_users
    @demo = FactoryGirl.create(:demo)
    @generic_characteristic_1 = FactoryGirl.create(:characteristic, :name => "Color", :allowed_values => %w(red orange yellow green blue indigo violet))
    @generic_characteristic_2 = FactoryGirl.create(:characteristic, :name => "Favorite Beatle", :allowed_values => %w(john paul george ringo))
    @generic_characteristic_3 = FactoryGirl.create(:characteristic, :name => "LOLPhrase", :allowed_values => %w(i can haz cheezburger))
    @demo_specific_characteristic_1 = FactoryGirl.create(:characteristic, :demo_specific, :name => "Brain size", :demo => @demo, :allowed_values => %w(low medium high))
    @demo_specific_characteristic_2 = FactoryGirl.create(:characteristic, :demo_specific, :name => "Favorite number", :demo => @demo, :allowed_values => %w(seven eight nine))
    @demo_specific_characteristic_3 = FactoryGirl.create(:characteristic, :demo_specific, :name => "MomPhrase", :demo => @demo, :allowed_values => %w(hi mom))

    %w(Here There Everywhere).each {|location_name| FactoryGirl.create(:location, name: location_name, demo: @demo)}
    @locations = @demo.locations.all

    @loser = FactoryGirl.create(:user, :demo => @demo)
    @reds = []
    @blues = []
    @greens = []

    14.times do |i|
      @reds << FactoryGirl.create(:user, :name => "Red Guy #{i}", :demo => @demo, :location => @locations[rand(3)], :employee_id => "reddude#{i}", :characteristics => {@generic_characteristic_1.id => "red"})
      @blues << FactoryGirl.create(:user, :name => "Blue Guy #{i}", :demo => @demo, :location => @locations[rand(3)], :employee_id => "bluedude#{i}", :characteristics => {@generic_characteristic_1.id => "blue"})
      @greens << FactoryGirl.create(:user, :name => "Green Guy #{i}", :demo => @demo, :location => @locations[rand(3)], :employee_id => "greendude#{i}", :characteristics => {@generic_characteristic_1.id => "green"})
    end

    %w(john john paul paul paul george george george george ringo ringo ringo ringo ringo).each_with_index do |name, i|
      [@reds, @blues, @greens].each do |color_array|
        color_array[i].characteristics[@generic_characteristic_2.id] = name
        color_array[i].save!
      end
    end

    %w(low low low low low low low medium medium medium high high high high).each_with_index do |name, i|
      [@reds, @blues, @greens].each do |color_array|
        color_array[i].characteristics[@demo_specific_characteristic_1.id] = name
        color_array[i].save!
      end
    end

    crank_off_dj
  end

  def expect_discrete_operators_to_not_be_present(characteristic_name)
    visit admin_demo_segmentation_path(@demo, as: an_admin)

    ['equals', 'does not equal'].each do |operator|
      select characteristic_name, :from => "segment_column[0]"
      expect {
        select "#{operator}", :from => "segment_operator[0]"
      }.to raise_error(Capybara::ElementNotFound, /Unable to find option "#{operator}"/)
    end
  end

  def expect_all_operators_to_work(characteristic_name, reference_value, users)
    expect_all_discrete_operators_to_work(characteristic_name, reference_value, users)
    expect_all_continuous_operators_to_work(characteristic_name, reference_value, users)
  end

  def expect_all_discrete_operators_to_work(characteristic_name, reference_value, users)
    visit admin_demo_segmentation_path(@demo, as: an_admin)

    select characteristic_name, :from => "segment_column[0]"
    select "equals", :from => "segment_operator[0]"
    fill_in "segment_value[0]", :with => reference_value
    click_button "Find segment"

    expect_content "Segmented by characteristics: #{characteristic_name} equals #{reference_value}"
    expect_content "USERS IN SEGMENT 1"
    click_link "Show users"
    expect_user_content(users[5])

    select characteristic_name, :from => "segment_column[0]"
    select "does not equal", :from => "segment_operator[0]"
    fill_in "segment_value[0]", :with => reference_value
    click_button "Find segment"

    expect_content "Segmented by characteristics: #{characteristic_name} does not equal #{reference_value}"
    expect_content "USERS IN SEGMENT 9"
    click_link "Show users"
    ((0..4).to_a + (6..9).to_a).each {|i| expect_user_content(users[i])}
  end

  def expect_all_continuous_operators_to_work(characteristic_name, reference_value, users)
    visit admin_demo_segmentation_path(@demo, as: an_admin)

    select characteristic_name, :from => "segment_column[0]"
    select "is greater than", :from => "segment_operator[0]"
    fill_in "segment_value[0]", :with => reference_value
    click_button "Find segment"

    expect_content "Segmented by characteristics: #{characteristic_name} is greater than #{reference_value}"
    expect_content "USERS IN SEGMENT 4"
    click_link "Show users"
    (6..9).to_a.each {|i| expect_user_content(users[i])}

    select characteristic_name, :from => "segment_column[0]"
    select "is less than", :from => "segment_operator[0]"
    fill_in "segment_value[0]", :with => reference_value
    click_button "Find segment"

    expect_content "Segmented by characteristics: #{characteristic_name} is less than #{reference_value}"
    expect_content "USERS IN SEGMENT 5"
    click_link "Show users"
    (0..4).to_a.each {|i| expect_user_content(users[i])}

    select characteristic_name, :from => "segment_column[0]"
    select "is greater than or equal to", :from => "segment_operator[0]"
    fill_in "segment_value[0]", :with => reference_value
    click_button "Find segment"

    expect_content "Segmented by characteristics: #{characteristic_name} is greater than or equal to #{reference_value}"
    expect_content "USERS IN SEGMENT 5"
    click_link "Show users"
    (5..9).to_a.each {|i| expect_user_content(users[i])}

    select characteristic_name, :from => "segment_column[0]"
    select "is less than or equal to", :from => "segment_operator[0]"
    fill_in "segment_value[0]", :with => reference_value
    click_button "Find segment"

    expect_content "Segmented by characteristics: #{characteristic_name} is less than or equal to #{reference_value}"
    expect_content "USERS IN SEGMENT 6"
    click_link "Show users"
    (0..5).to_a.each {|i| expect_user_content(users[i])}
  end

  def expect_user_content(user)
    expect_content "#{user.name}: #{user.email} (#{user.id})"
  end

  context "segmenting users" do
    it "sees users segmented by one characteristic", :js => true do
      # Basic segmentation on just one characteristic
      create_characteristics_and_users
      
      visit admin_demo_segmentation_path(@demo, as: an_admin)

      select "Color", :from => "segment_column[0]"
      select "red", :from => "segment_value[0]"

      click_button "Find segment"

      expect_content "Segmented by characteristics: Color equals red"
      expect_content "USERS IN SEGMENT 14"
      click_link "Show users"
      @reds.each { |red| expect_user_content red }
    end

    it "sees users segmented by two characteristics", :js => true do
      # Segmenting on multiple characteristics
      create_characteristics_and_users
      
      visit admin_demo_segmentation_path(@demo, as: an_admin)

      select "Color", :from => "segment_column[0]"
      select "red", :from => "segment_value[0]"
      click_link "Add characteristic"
      select "Favorite Beatle", :from => "segment_column[1]"
      select "george", :from => "segment_value[1]"

      click_button "Find segment"

      expect_content "Color equals red"
      expect_content "Favorite Beatle equals george"
      expect_content "USERS IN SEGMENT 4"
      click_link "Show users"
      [@reds[5], @reds[6], @reds[7], @reds[8]].each { |red| expect_user_content red }
    end

    it "sees users segmented by three characteristics", :js => true do
      # How about three?
      create_characteristics_and_users
      
      visit admin_demo_segmentation_path(@demo, as: an_admin)
      
      select "Color", :from => "segment_column[0]"
      select "green", :from => "segment_value[0]"
      click_link "Add characteristic"
      select "Favorite Beatle", :from => "segment_column[1]"
      select "ringo", :from => "segment_value[1]"
      click_link "Add characteristic"
      select "Brain size", :from => "segment_column[2]"
      select "medium", :from => "segment_value[2]"

      click_button "Find segment"

      expect_content "Color equals green"
      expect_content "Favorite Beatle equals ringo"
      expect_content "Brain size equals medium"
      expect_content "USERS IN SEGMENT 1"

      click_link "Show users"
      expect_user_content @greens[9]
    end
  
    it "characteristics can be removed", :js => true do
      create_characteristics_and_users
      
      visit admin_demo_segmentation_path(@demo, as: an_admin)

      select "Color", :from => "segment_column[0]"
      select "green", :from => "segment_value[0]"

      click_link "Add characteristic"
      select "Favorite Beatle", :from => "segment_column[1]"
      select "ringo", :from => "segment_value[1]"

      click_link "Add characteristic"
      select "Brain size", :from => "segment_column[2]"
      select "medium", :from => "segment_value[2]"

      click_link "Add characteristic"
      select "Favorite number", :from => "segment_column[3]"
      select "nine", :from => "segment_value[3]"

      click_link 'remove_this_characteristic_1'
      click_link 'remove_this_characteristic_3'

      click_button "Find segment"

      expect_content "Color equals green"
      expect_content "Brain size equals medium"
      expect_content "USERS IN SEGMENT 3"

      expect_no_content "Favorite Beatle equals ringo"
      expect_no_content "Favorite number equals nine"

      click_link "Show users"
      (7..9).each { |i| expect_user_content @greens[i] }
    end

    it "sees users segmented by a not-equals operator", :js => true do
      create_characteristics_and_users
      
      visit admin_demo_segmentation_path(@demo, as: an_admin)
      
      select "Color", :from => "segment_column[0]"
      select "red", :from => "segment_value[0]"
      select "does not equal", :from => "segment_operator[0]"

      click_link "Add characteristic"

      select "Favorite Beatle", :from => "segment_column[1]"
      select "ringo", :from => "segment_value[1]"
      select "does not equal", :from => "segment_operator[1]"

      click_button "Find segment"

      expect_content "Color does not equal red"
      expect_content "Favorite Beatle does not equal ringo"
      expect_content "USERS IN SEGMENT 19"

      click_link "Show users"
      0.upto(8) do |i|
        expect_user_content @blues[i]
        expect_user_content @greens[i]
      end

      expect_user_content @loser
    end

    it "sees link to each segmented user", :js => true do
      create_characteristics_and_users
      
      visit admin_demo_segmentation_path(@demo, as: an_admin)
      
      select "Color", :from => "segment_column[0]"
      select "red", :from => "segment_value[0]"

      click_button "Find segment"
      click_link "Show users"

      first_red = @reds[0]
      click_link "#{first_red.name}: #{first_red.email} (#{first_red.id})"
      should_be_on edit_admin_demo_user_path(first_red.demo, first_red)
    end

    it "segments in a way that no employees match", :js => true do
      create_characteristics_and_users
      
      visit admin_demo_segmentation_path(@demo, as: an_admin)
      
      # And let's go for a shutout
      select "Color", :from => "segment_column[0]"
      select "green", :from => "segment_value[0]"
      click_link "Add characteristic"
      select "Favorite Beatle", :from => "segment_column[1]"
      select "john", :from => "segment_value[1]"
      click_link "Add characteristic"
      select "Brain size", :from => "segment_column[2]"
      select "high", :from => "segment_value[2]"

      click_button "Find segment"

      expect_content "Color equals green"
      expect_content "Favorite Beatle equals john"
      expect_content "Brain size equals high"
      expect_content "USERS IN SEGMENT 0"
    end

    it "segments in such a way (like by choosing no characteristics) that matches all users", :js => true do
      create_characteristics_and_users
      
      visit admin_demo_segmentation_path(@demo, as: an_admin)
      
      click_button "Find segment"
      expect_content "USERS IN SEGMENT 43"

      click_link "Show users"
      @demo.users.each { |user| expect_user_content user }
    end

    it 'should allow segmentation information to be downloaded in CSV format' do
      create_characteristics_and_users
      admin = an_admin
      visit admin_demo_segmentation_path(@demo, as: admin)

      # We rig this up this way because it seems like Poltergeist doesn't get
      # the body of the CSV file when we click the link for same, even though
      # the response content-type header does get set to text/csv. But 
      # Rack::Test can't operate the segmentation interface properly due to
      # the JS that makes it work. So...we cheat.

      User::SegmentationResults.create(owner_id: admin.id, explanation: "Rigged", found_user_ids: @reds.map(&:id))
      click_link "Show user names and emails in CSV"
      page.response_headers['Content-Type'].should =~ %r{^text/csv}
      expect_no_content "<html>"
      expect_no_content "<head>"
      expect_no_content "<body>"
      expect_content "Name,Email,ID,Location,Employee ID"

      lines = page.body.split("\n")
      @reds.each { |red| lines.should include(CSV.generate_line([red.name, red.email, red.id, red.location.name, red.employee_id]).strip) }
    end
  end

  context "segmenting on a boolean characteristic" do
    it "should work with equals and does-not-equal", :js => true do
      create_characteristics_and_users
      characteristic = FactoryGirl.create(:characteristic, :boolean, name: "Likes cheese")
      demo = FactoryGirl.create(:demo)
      users = []

      # This leaves the "Likes cheese" characteristic set to true on users
      # 0, 1, 2, 6, 7, and 8; and set to false on 3, 4, 5, 9, 10 and 11.
      2.times do
        3.times { users << FactoryGirl.create(:user, demo: demo, characteristics: {characteristic.id => true}) }
        3.times { users << FactoryGirl.create(:user, demo: demo, characteristics: {characteristic.id => false}) }
      end

      crank_dj_clear

      
      visit admin_demo_segmentation_path(demo, as: an_admin)
      select "Likes cheese", :from => "segment_column[0]"
      select "equals", :from => "segment_operator[0]"
      check "segment_value[0]"

      click_button "Find segment"

      expect_content "Segmented by characteristics: Likes cheese equals true"
      expect_content "USERS IN SEGMENT 6"
      click_link "Show users"
      [0, 1, 2, 6, 7, 8].each {|i| expect_user_content(users[i])}

      select "Likes cheese", :from => "segment_column[0]"
      select "does not equal", :from => "segment_operator[0]"
      check "segment_value[0]"

      click_button "Find segment"

      expect_content "Segmented by characteristics: Likes cheese does not equal true"
      expect_content "USERS IN SEGMENT 6"
      click_link "Show users"
      [3, 4, 5, 9, 10, 11].each {|i| expect_user_content(users[i])}

      select "Likes cheese", :from => "segment_column[0]"
      select "equals", :from => "segment_operator[0]"

      click_button "Find segment"

      expect_content "Segmented by characteristics: Likes cheese equals false"
      expect_content "USERS IN SEGMENT 6"
      click_link "Show users"
      [3, 4, 5, 9, 10, 11].each {|i| expect_user_content(users[i])}

      select "Likes cheese", :from => "segment_column[0]"
      select "does not equal", :from => "segment_operator[0]"

      click_button "Find segment"

      expect_content "Segmented by characteristics: Likes cheese does not equal false"
      expect_content "USERS IN SEGMENT 6"
      click_link "Show users"
      [0, 1, 2, 6, 7, 8].each {|i| expect_user_content(users[i])}
    end
  end

  context "of numeric type" do
    it "should work with all operators", :js => true do
      characteristic = FactoryGirl.create(:characteristic, :number, :name => "Foo count")
      @demo = FactoryGirl.create(:demo)
      users = []
      0.upto(9) do |i|
        users << FactoryGirl.create(:user, :demo => @demo, :characteristics => {characteristic.id => i})
      end
      crank_dj_clear

      

      expect_all_operators_to_work "Foo count", 5, users
    end

    context "segmenting on a continuous characteristic" do
      context "of date type" do
        it "should work with all continuous operators, but not discrete one", :js => true do
          @demo = FactoryGirl.create(:demo)
          reference_value = "May 10, 2010"
          reference_date = Chronic.parse(reference_value).to_date

          characteristic = FactoryGirl.create(:characteristic, :date, :name => "Date of last decapitation")
          users = []
          (-5).upto(4) do |i|
            users << FactoryGirl.create(:user, :demo => @demo, :characteristics => {characteristic.id => (reference_date + i.days).to_s})
          end
          crank_dj_clear
          expect_all_continuous_operators_to_work "Date of last decapitation", reference_date, users
          expect_discrete_operators_to_not_be_present "Date of last decapitation"
        end
      end

      context "of time type" do
        it "should work with all continuous operators, but not discrete ones", :js => true do
          @demo = FactoryGirl.create(:demo)
          reference_value = "May 10, 2010, 12:00 PM"
          reference_time = Chronic.parse(reference_value)

          characteristic = FactoryGirl.create(:characteristic, :time, :name => "Lunchtime")
          users = []
          -5.upto(4) do |i|
            users << FactoryGirl.create(:user, :demo => @demo, :characteristics => {characteristic.id => (reference_time + i.hours).to_s})
          end
          crank_dj_clear

          
          expect_all_continuous_operators_to_work "Lunchtime", reference_time, users
          expect_discrete_operators_to_not_be_present "Lunchtime"
        end
      end
    end
  end

  it "can segment on location", :js => true do
    Location.delete_all
    Demo.delete_all
    @demo = FactoryGirl.create(:demo)
    @demo.update_attributes(name: "AwesomeCo")
    other_demo = FactoryGirl.create(:demo, name: "Dewey, Cheatem and Howe")

    demo_location_names = ["Puddingville", "North Southerton", "Blahdeblahham"]
    other_demo_location_names = ["Under the Sea", "Pantstown"]
    demo_location_names.each {|location_name| FactoryGirl.create(:location, demo: @demo, name: location_name)}
    other_demo_location_names.each {|location_name| FactoryGirl.create(:location, demo: other_demo, name: location_name)}

    Location.all.each {|location| FactoryGirl.create(:user, location: location, demo: location.demo)}
    crank_dj_clear

    
    visit admin_demo_segmentation_path(@demo, as: an_admin)

    select "Location", :from => "segment_column[0]"
    select "equals", :from => "segment_operator[0]"

    place_options = page.all('#segment_value_0 option').map(&:text)
    demo_location_names.each{|demo_location_name| place_options.should include("#{demo_location_name} (AwesomeCo)")}
    other_demo_location_names.each{|other_demo_location_name| place_options.should_not include("#{other_demo_location_name} (Dewey, Cheatem and Howe)")}
    select "North Southerton (AwesomeCo)", :from => "segment_value[0]"

    click_button "Find segment"

    expect_content "Segmented by characteristics: Location equals North Southerton (AwesomeCo)"
    expect_content "USERS IN SEGMENT 1"

    expected_location = Location.find_by_name "North Southerton"
    expected_user = User.find_by_location_id(expected_location.id)
  
    click_link "Show users"
    expect_user_content expected_user
    
    select "Location", :from => "segment_column[0]"
    select "does not equal", :from => "segment_operator[0]"
    select "North Southerton (AwesomeCo)", :from => "segment_value[0]"
   
    click_button "Find segment"

    expect_content "Segmented by characteristics: Location does not equal North Southerton (AwesomeCo)"
    expect_content "USERS IN SEGMENT 2"

    click_link "Show users"
    (@demo.users - [expected_user]).each {|user| expect_user_content(user)}
  end

  it "can segment on multiple location not-equal parameters", :js => true do
    Location.delete_all
    Demo.delete_all
    @demo = FactoryGirl.create(:demo, name: 'MilesDavis')

    { 
      "Boston"     => 2,
      "Cambridge"  => 1,
      "Brookline"  => 5,
      "Somerville" => 8
    }.each do |location_name, user_count|
      location = FactoryGirl.create(:location, name: location_name, demo: @demo)
      user_count.times {FactoryGirl.create(:user, location: location, demo: @demo) }
    end

    crank_dj_clear
    visit admin_demo_segmentation_path(@demo, as: an_admin)

    select "Location", :from => "segment_column[0]"
    select "does not equal", :from => "segment_operator[0]"
    select "Cambridge (MilesDavis)", :from => "segment_value[0]"

    click_link "Add characteristic"

    select "Location", :from => "segment_column[1]"
    select "does not equal", :from => "segment_operator[1]"
    select "Somerville (MilesDavis)", :from => "segment_value[1]"

    click_button "Find segment"

    expect_content "USERS IN SEGMENT 7"
  end

  it "can segment on location when the location name has parentheses", :js => true do
    Location.delete_all
    Demo.delete_all
    @demo = FactoryGirl.create(:demo)
    @demo.update_attributes(name: "AwesomeCo")
    other_demo = FactoryGirl.create(:demo, name: "Dewey, Cheatem and Howe")

    demo_location_names = ["Puddingville (Site A)", "Puddingville (Site B)", "Puddingville (Down The Road A Little)", "Pantstown"]
    other_demo_location_names = ["Under the Sea", "Pantstown"]
    demo_location_names.each {|location_name| FactoryGirl.create(:location, demo: @demo, name: location_name)}
    other_demo_location_names.each {|location_name| FactoryGirl.create(:location, demo: other_demo, name: location_name)}

    Location.all.each {|location| 3.times{FactoryGirl.create(:user, location: location, demo: location.demo)}}
    crank_dj_clear

    
    visit admin_demo_segmentation_path(@demo, as: an_admin)

    select "Location", :from => "segment_column[0]"
    select "equals", :from => "segment_operator[0]"
    select "Puddingville (Site B) (AwesomeCo)", :from => "segment_value[0]"
    click_button "Find segment"

    expect_content "Segmented by characteristics: Location equals Puddingville (Site B) (AwesomeCo)"
    expect_content "USERS IN SEGMENT 3"

    expected_location = Location.find_by_name "Puddingville (Site B)"
    expected_users = User.where(location_id: expected_location.id)
  
    click_link "Show users"
    expected_users.each {|expected_user| expect_user_content expected_user}
  end

  it 'can segment on points', :js => true do
    @demo = FactoryGirl.create(:demo)
    users = []
    0.upto(9) do |points|
      users << FactoryGirl.create(:user, :demo => @demo, :points => points)
    end
    crank_dj_clear

    
    expect_all_operators_to_work "Points", 5, users
  end

  it 'can segment on date of birth, and discrete operators should not be present', :js => true do
    @demo = FactoryGirl.create(:demo)

    reference_value = "May 10, 2010"
    reference_date = Chronic.parse(reference_value).to_date

    users = []
    (-5).upto(4) do |i|
      users << FactoryGirl.create(:user, :demo => @demo, :date_of_birth => (reference_date + i.days).to_s)
    end
    crank_dj_clear

    

    expect_all_continuous_operators_to_work "Date of birth", reference_date, users
    expect_discrete_operators_to_not_be_present "Date of birth"
  end

  it 'can segment on accepted_invitation_at, and discrete operators should not be present', :js => true do
    @demo = FactoryGirl.create(:demo)

    reference_value = "May 10, 2010, 9:00 AM"
    reference_time = Chronic.parse(reference_value)

    users = []
    (-5).upto(4) do |i|
      users << FactoryGirl.create(:user, :demo => @demo, :accepted_invitation_at => (reference_time + i.days).to_s)
    end
    crank_dj_clear

    

    expect_all_continuous_operators_to_work "Joined at", reference_time, users
    expect_discrete_operators_to_not_be_present "Joined at"
  end

  it 'can segment on gender', :js => true do
    @demo = FactoryGirl.create(:demo)

    expected_users = {'male' => [], 'female' => [], 'other' => []}
    3.times do 
      expected_users['male'] << FactoryGirl.create(:user, demo: @demo, gender: 'male')
      expected_users['female'] << FactoryGirl.create(:user, demo: @demo, gender: 'female')
      expected_users['other'] << FactoryGirl.create(:user, demo: @demo, gender: 'other')
    end

    crank_dj_clear

    
    visit admin_demo_segmentation_path(@demo, as: an_admin)

    %w(male female other).each do |gender_name|
      select 'Gender',    :from => "segment_column[0]"
      select "equals",    :from => "segment_operator[0]"
      select gender_name, :from => "segment_value[0]"
      click_button "Find segment"

      expect_content "Segmented by characteristics: Gender equals #{gender_name}"
      expect_content "USERS IN SEGMENT 3"
      click_link "Show users"
      expected_users[gender_name].each{|user| expect_user_content(user)}

      select 'Gender',         :from => "segment_column[0]"
      select "does not equal", :from => "segment_operator[0]"
      select gender_name,      :from => "segment_value[0]"
      click_button "Find segment"

      expect_content "Segmented by characteristics: Gender does not equal #{gender_name}"
      expect_content "USERS IN SEGMENT 6"
      click_link "Show users"
      other_keys = expected_users.keys - [gender_name]
      other_keys.each do |other_key|
        expected_users[other_key].each{|user| expect_user_content(user)}
      end
    end
  end

  it "can segment on has_phone_number", :js => true do
    @demo = FactoryGirl.create(:demo)

    users_with_phone = []
    users_without_phone = []

    4.times {users_with_phone << FactoryGirl.create(:user, :with_phone_number, demo: @demo)}
    3.times {users_without_phone << (FactoryGirl.create :user, demo: @demo)}
    crank_dj_clear

    
    visit admin_demo_segmentation_path(@demo, as: an_admin)

    select 'Has phone number', :from => "segment_column[0]"
    select "equals",  :from => "segment_operator[0]"
    check "segment_value[0]"

    click_button "Find segment"

    expect_content "Segmented by characteristics: Has phone number equals true"
    expect_content "USERS IN SEGMENT 4"
    click_link "Show users"
    users_with_phone.each {|claimed_user| expect_user_content(claimed_user)}

    select 'Has phone number', :from => "segment_column[0]"
    select "equals",  :from => "segment_operator[0]"

    click_button "Find segment"

    expect_content "Segmented by characteristics: Has phone number equals false"
    expect_content "USERS IN SEGMENT 3"
    click_link "Show users"
    users_without_phone.each {|unclaimed_user| expect_user_content(unclaimed_user)}
  end

  it "can segment on claimed", :js => true do
    @demo = FactoryGirl.create(:demo)

    4.times {FactoryGirl.create :user, :claimed, demo: @demo}
    3.times {FactoryGirl.create :user, demo: @demo}
    crank_dj_clear

    
    visit admin_demo_segmentation_path(@demo, as: an_admin)

    select 'Joined?', :from => "segment_column[0]"
    select "equals",  :from => "segment_operator[0]"
    check "segment_value[0]"

    click_button "Find segment"

    expect_content "Segmented by characteristics: Joined? equals true"
    expect_content "USERS IN SEGMENT 4"
    click_link "Show users"
    @demo.users.claimed.each {|claimed_user| expect_user_content(claimed_user)}

    select 'Joined?', :from => "segment_column[0]"
    select "does not equal",  :from => "segment_operator[0]"
    check "segment_value[0]"

    click_button "Find segment"

    expect_content "Segmented by characteristics: Joined? does not equal true"
    expect_content "USERS IN SEGMENT 3"
    click_link "Show users"
    @demo.users.unclaimed.each {|unclaimed_user| expect_user_content(unclaimed_user)}

    select 'Joined?', :from => "segment_column[0]"
    select "equals",  :from => "segment_operator[0]"

    click_button "Find segment"

    expect_content "Segmented by characteristics: Joined? equals false"
    expect_content "USERS IN SEGMENT 3"
    click_link "Show users"
    @demo.users.unclaimed.each {|unclaimed_user| expect_user_content(unclaimed_user)}

    select 'Joined?', :from => "segment_column[0]"
    select "does not equal",  :from => "segment_operator[0]"

    click_button "Find segment"

    expect_content "Segmented by characteristics: Joined? does not equal false"
    expect_content "USERS IN SEGMENT 4"
    click_link "Show users"
    @demo.users.claimed.each {|claimed_user| expect_user_content(claimed_user)}
  end

  it 'can display large numbers of users', :js => true do
    # We need a large number of IDs to expose the problem caused by trying to
    # jam them all into the URI, but creating 1000Users in the DB for this 
    # test takes unfeasibly long. So we cheat. And the amount of trouble we
    # have to go to to cheat is illustrative of why we don't more often.

    @demo = FactoryGirl.create(:demo)
    highest_user_id = User.count > 0 ? User.order("id DESC").last.id : 0
    first_fake_id = highest_user_id + 1
    fake_ids = (first_fake_id..first_fake_id + 999).to_a
    Demo.any_instance.stubs(:user_ids).returns(fake_ids)

    unsaved_users = []
    1000.times do |i| 
      unsaved_user = FactoryGirl.build(:user, :demo => @demo)
      unsaved_user.stubs(:id).returns(fake_ids[i])
      unsaved_user.stubs(:slug).returns("jimearljones_#{fake_ids[i]}")
      unsaved_users << unsaved_user
    end
    spot_check_users = [unsaved_users[0], unsaved_users[500], unsaved_users[999]]

    fake_arel = Object.new
    fake_arel.stubs(:where).returns(unsaved_users)
    Demo.any_instance.stubs(:users).returns(unsaved_users)
    %w(alphabetical where claimed with_phone_number with_game_referrer).each do |method_name|
      unsaved_users.stubs(method_name.to_s).returns(unsaved_users)
    end
 
    
    visit admin_demo_path(@demo, as: an_admin)

    click_link "Segment users"
    click_button "Find segment"
    expect_content "USERS IN SEGMENT 1000"

    click_link "Show users"

    spot_check_users.each { |user| expect_user_content user }
  end

  it 'should have a proper link from somewhere' do
    @demo = FactoryGirl.create(:demo)
    
    visit admin_demo_path(@demo, as: an_admin)
    click_link "Segment users"
    should_be_on admin_demo_segmentation_path(@demo)
  end

  it 'should give the user an idea of when the segment was looked up', :js => true do
    Timecop.freeze(Time.now)
    @demo = FactoryGirl.create(:demo)

    
    visit admin_demo_segmentation_path(@demo, as: an_admin)

    select 'Joined?', :from => "segment_column[0]"
    select "equals",  :from => "segment_operator[0]"
    check "segment_value[0]"
    click_button 'Find segment'
    
    expect_content 'USERS IN SEGMENT 0'
    expect_content 'Searched less than a minute ago'

    Timecop.travel(10.minutes)
    Timecop.freeze(Time.now)

    select 'Joined?', :from => "segment_column[0]"
    select "equals",  :from => "segment_operator[0]"
    check "segment_value[0]"
    click_button 'Find segment'
    
    expect_content 'USERS IN SEGMENT 0'
    expect_content 'Searched less than a minute ago'

    Timecop.return
  end

  context 'blank search fields' do
    SEGMENTATION_ERROR_MESSAGE = 'One or more of your characteristic fields is blank'

    let(:demo) { FactoryGirl.create(:demo) }

    before(:each) do
      
      visit admin_demo_segmentation_path(demo, as: an_admin)
    end

    it 'detects and reports blank value', :js => true  do
      select 'Gender', :from => "segment_column[0]"

      click_link "Add characteristic"
      select 'Points', :from => "segment_column[1]"

      click_link "Add characteristic"
      select 'Has phone number', :from => "segment_column[2]"

      click_button 'Find segment'
      expect_content SEGMENTATION_ERROR_MESSAGE

      fill_in "segment_value[1]", :with => 3

      click_button 'Find segment'
      expect_no_content SEGMENTATION_ERROR_MESSAGE
    end

    it 'detects and reports blank characteristic (only when multiple segment criteria)', :js => true do
      click_link "Add characteristic"  # Add another blank segment criterion

      click_button 'Find segment'
      expect_content SEGMENTATION_ERROR_MESSAGE

      # First one will now be okay, but second blank one still remains
      select 'Gender', :from => "segment_column[0]"
      click_button 'Find segment'
      expect_content SEGMENTATION_ERROR_MESSAGE

      click_link 'remove_this_characteristic_1'  # Remove the blank one which is causing the problem
      click_button 'Find segment'
      expect_no_content SEGMENTATION_ERROR_MESSAGE
    end
  end
end
