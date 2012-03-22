require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "Admin Segments Users By Characteristics" do
  scenario "sees users segmented by characteristics", :js => true do
    @demo = Factory :demo
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

    signin_as_admin
    visit admin_demo_segmentation_path(@demo)

    select "Color", :from => "segment_column[0]"
    select "red", :from => "segment_value[0]"

    click_button "Find segment"

    expect_content "Segmenting on: Color is red"
    expect_content "14 users in segment"
    click_link "Show users"
    @reds.each do |red|
      expect_content "#{red.name}: #{red.email}"
    end

    pending
  end

  scenario 'should have a proper link from somewhere'

  scenario 'should not show users from another demo'
end
