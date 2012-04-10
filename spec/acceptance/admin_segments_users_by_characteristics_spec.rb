require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "Admin segmentation" do
  before(:each) do
    @demo = Factory :demo
    signin_as_admin
  end

  def expect_user_content(user)
    expect_content "#{user.name}: #{user.email} (#{user.id})"
  end

  context "segmenting users" do
    before(:each) do
      @generic_characteristic_1 = Factory :characteristic, :name => "Color", :allowed_values => %w(red orange yellow green blue indigo violet)
      @generic_characteristic_2 = Factory :characteristic, :name => "Favorite Beatle", :allowed_values => %w(john paul george ringo)
      @generic_characteristic_3 = Factory :characteristic, :name => "LOLPhrase", :allowed_values => %w(i can haz cheezburger)
      @demo_specific_characteristic_1 = Factory :demo_specific_characteristic, :name => "Height", :demo => @demo, :allowed_values => %w(low medium high)
      @demo_specific_characteristic_2 = Factory :demo_specific_characteristic, :name => "Favorite number", :demo => @demo, :allowed_values => %w(seven eight nine)
      @demo_specific_characteristic_3 = Factory :demo_specific_characteristic, :name => "MomPhrase", :demo => @demo, :allowed_values => %w(hi mom)

      @loser = Factory :user, :demo => @demo
      @reds = []
      @blues = []
      @greens = []

      14.times do |i|
        @reds << Factory(:user, :name => "Red Guy #{i}", :demo => @demo, :characteristics => {@generic_characteristic_1.id => "red"})
        @blues << Factory(:user, :name => "Blue Guy #{i}", :demo => @demo, :characteristics => {@generic_characteristic_1.id => "blue"})
        @greens << Factory(:user, :name => "Green Guy #{i}", :demo => @demo, :characteristics => {@generic_characteristic_1.id => "green"})
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

      expect_content "Segmenting on: Color is red"
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

      expect_content "Color is red"
      expect_content "Favorite Beatle is george"
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

      expect_content "Color is green"
      expect_content "Favorite Beatle is ringo"
      expect_content "Height is medium"
      expect_content "1 users in segment"

      click_link "Show users"
      expect_user_content @greens[9]
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

      expect_content "Color is green"
      expect_content "Favorite Beatle is john"
      expect_content "Height is high"
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

      expect_content "Segmenting on: Color is red"
      expect_content "14 users in segment"
     
      click_link "Show user names and emails in CSV"
      page.response_headers['Content-Type'].should =~ %r{^text/csv}
      expect_content "Name,Email,ID"
      @reds.each { |red| expect_content CSV.generate_line([red.name, red.email, red.id]) }
    end
  end

  scenario 'should have a proper link from somewhere' do
    visit admin_demo_path(@demo)
    click_link "Segment users"
    should_be_on admin_demo_segmentation_path(@demo)
  end
end
