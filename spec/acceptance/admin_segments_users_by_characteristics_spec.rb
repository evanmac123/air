require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "Admin segmentation" do
  before(:each) do
    @demo = FactoryGirl.create(:demo)
    signin_as_admin
  end

  def expect_user_content(user)
    expect_content "#{user.name}: #{user.email} (#{user.id})"
  end

  context "segmenting users" do
    before(:each) do
      @generic_characteristic_1 = FactoryGirl.create(:characteristic, :name => "Color", :allowed_values => %w(red orange yellow green blue indigo violet))
      @generic_characteristic_2 = FactoryGirl.create(:characteristic, :name => "Favorite Beatle", :allowed_values => %w(john paul george ringo))
      @generic_characteristic_3 = FactoryGirl.create(:characteristic, :name => "LOLPhrase", :allowed_values => %w(i can haz cheezburger))
      @demo_specific_characteristic_1 = FactoryGirl.create(:demo_specific_characteristic, :name => "Height", :demo => @demo, :allowed_values => %w(low medium high))
      @demo_specific_characteristic_2 = FactoryGirl.create(:demo_specific_characteristic, :name => "Favorite number", :demo => @demo, :allowed_values => %w(seven eight nine))
      @demo_specific_characteristic_3 = FactoryGirl.create(:demo_specific_characteristic, :name => "MomPhrase", :demo => @demo, :allowed_values => %w(hi mom))

      @loser = FactoryGirl.create(:user, :demo => @demo)
      @reds = []
      @blues = []
      @greens = []

      14.times do |i|
        @reds << FactoryGirl.create(:user, :name => "Red Guy #{i}", :demo => @demo, :characteristics => {@generic_characteristic_1.id => "red"})
        @blues << FactoryGirl.create(:user, :name => "Blue Guy #{i}", :demo => @demo, :characteristics => {@generic_characteristic_1.id => "blue"})
        @greens << FactoryGirl.create(:user, :name => "Green Guy #{i}", :demo => @demo, :characteristics => {@generic_characteristic_1.id => "green"})
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

      visit admin_demo_segmentation_path(@demo)
    end

    scenario "sees users segmented by one characteristic", :js => true do
      # Basic segmentation on just one characteristic
      select "Color", :from => "segment_column[0]"
      select "red", :from => "segment_value[0]"

      click_button "Find segment"

      expect_content "Segmenting on: Color equals red"
      expect_content "14 users in segment"
      click_link "Show users"
      @reds.each { |red| expect_user_content red }
    end

    scenario "sees users segmented by two characteristics", :js => true do
      # Segmenting on multiple characteristics
      select "Color", :from => "segment_column[0]"
      select "red", :from => "segment_value[0]"
      click_link "Segment on more characteristics"
      select "Favorite Beatle", :from => "segment_column[1]"
      select "george", :from => "segment_value[1]"

      click_button "Find segment"

      expect_content "Color equals red"
      expect_content "Favorite Beatle equals george"
      expect_content "4 users in segment"
      click_link "Show users"
      [@reds[5], @reds[6], @reds[7], @reds[8]].each { |red| expect_user_content red }
    end

    scenario "sees users segmented by three characteristics", :js => true do
      # How about three?
      
      select "Color", :from => "segment_column[0]"
      select "green", :from => "segment_value[0]"
      click_link "Segment on more characteristics"
      select "Favorite Beatle", :from => "segment_column[1]"
      select "ringo", :from => "segment_value[1]"
      click_link "Segment on more characteristics"
      select "Height", :from => "segment_column[2]"
      select "medium", :from => "segment_value[2]"

      click_button "Find segment"

      expect_content "Color equals green"
      expect_content "Favorite Beatle equals ringo"
      expect_content "Height equals medium"
      expect_content "1 users in segment"

      click_link "Show users"
      expect_user_content @greens[9]
    end
  
    scenario "sees users segmented by a not-equals operator", :js => true do
      select "Color", :from => "segment_column[0]"
      select "red", :from => "segment_value[0]"
      select "does not equal", :from => "segment_operator[0]"

      click_link "Segment on more characteristics"

      select "Favorite Beatle", :from => "segment_column[1]"
      select "ringo", :from => "segment_value[1]"
      select "does not equal", :from => "segment_operator[1]"

      click_button "Find segment"

      expect_content "Color does not equal red"
      expect_content "Favorite Beatle does not equal ringo"
      expect_content "18 users in segment"

      click_link "Show users"
      0.upto(8) do |i|
        expect_user_content @blues[i]
        expect_user_content @greens[i]
      end
    end

    scenario "sees link to each segmented user", :js => true do
      select "Color", :from => "segment_column[0]"
      select "red", :from => "segment_value[0]"

      click_button "Find segment"
      click_link "Show users"

      first_red = @reds[0]
      click_link "#{first_red.name}: #{first_red.email} (#{first_red.id})"
      should_be_on edit_admin_demo_user_path(first_red.demo, first_red)
    end

    scenario "segments in a way that no employees match", :js => true do
      # And let's go for a shutout
      select "Color", :from => "segment_column[0]"
      select "green", :from => "segment_value[0]"
      click_link "Segment on more characteristics"
      select "Favorite Beatle", :from => "segment_column[1]"
      select "john", :from => "segment_value[1]"
      click_link "Segment on more characteristics"
      select "Height", :from => "segment_column[2]"
      select "high", :from => "segment_value[2]"

      click_button "Find segment"

      expect_content "Color equals green"
      expect_content "Favorite Beatle equals john"
      expect_content "Height equals high"
      expect_content "0 users in segment"
      expect_no_content "Show users"
    end

    scenario "segments in such a way (like by choosing no characteristics) that matches all users", :js => true do
      click_button "Find segment"
      expect_content "43 users in segment"

      click_link "Show users"
      @demo.users.each { |user| expect_user_content user }
    end

    scenario 'should allow segmentation information to be downloaded in CSV format', :js => true do
      select "Color", :from => "segment_column[0]"
      select "red", :from => "segment_value[0]"

      click_button "Find segment"

      expect_content "Segmenting on: Color equals red"
      expect_content "14 users in segment"
     
      click_link "Show user names and emails in CSV"
      page.response_headers['Content-Type'].should =~ %r{^text/csv}
      expect_no_content "<html>"
      expect_no_content "<head>"
      expect_no_content "<body>"
      expect_content "Name,Email,ID"

      lines = page.body.split("\n")
      @reds.each { |red| lines.should include(CSV.generate_line([red.name, red.email, red.id]).strip) }
    end
  end

  scenario 'can display large numbers of users', :js => true do
    # We need a large number of IDs to expose the problem caused by trying to
    # jam them all into the URI, but creating 1000 users in the DB for this 
    # test takes unfeasibly long. So we cheat. And the amount of trouble we
    # have to go to to cheat is illustrative of why we don't more often.

    highest_user_id = User.order("id DESC").last.id
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
    %w(alphabetical where claimed).each do |method_name|
      unsaved_users.stubs(method_name.to_s).returns(unsaved_users)
    end
   
    visit admin_demo_path(@demo)

    click_link "Segment users"
    click_button "Find segment"
    expect_content "1000 users in segment"

    click_link "Show user names and emails in CSV"
    expect_no_content "Request-URI Too Large"
    spot_check_users.each do |unsaved_user|
      expect_content (CSV.generate_line([unsaved_user.name, unsaved_user.email, unsaved_user.id]).strip)
    end

    visit admin_demo_path(@demo)

    click_link "Segment users"
    click_button "Find segment"
    expect_content "1000 users in segment"
    click_link "Show users"

    spot_check_users.each { |user| expect_user_content user }
  end

  scenario 'should have a proper link from somewhere' do
    visit admin_demo_path(@demo)
    click_link "Segment users"
    should_be_on admin_demo_segmentation_path(@demo)
  end
end
