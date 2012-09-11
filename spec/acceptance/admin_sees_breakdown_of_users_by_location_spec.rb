require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "Admin sees breakdown of users by location" do
  before(:each) do
    Demo.find_each {|f| f.destroy}
    @farm = FactoryGirl.create(:demo, name: 'LocatoCo')
    @north = FactoryGirl.create(:location, demo: @farm, name: 'North Pole')
    @detroit = FactoryGirl.create(:location, demo: @farm, name: 'Detroit')
    @whoville = FactoryGirl.create(:location, demo: @farm, name: 'Whoville')
    @emptyville = FactoryGirl.create(:location, demo: @farm, name: 'Emptyville')
    3.times do 
      FactoryGirl.create(:user, location: @north)
    end
    2.times do 
      FactoryGirl.create(:user, location: @detroit)
    end
    FactoryGirl.create(:user, location: @whoville)
    signin_as_admin
  end

  it "should display who's in what location " do
    visit admin_demo_reports_location_breakdown_path(@farm)
    page.should have_content("Detroit 2 Emptyville 0 North Pole 3 Whoville 1")
  end
end
