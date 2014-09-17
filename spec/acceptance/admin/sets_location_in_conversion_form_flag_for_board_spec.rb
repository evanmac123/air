require 'acceptance/acceptance_helper'

feature "Admin sets whether board displays the location autocomplete elements in the conversion form" do
  before do
    @demo = FactoryGirl.create(:demo)
  end

  def check_use_location_in_conversion
    check "demo_use_location_in_conversion"
  end

  def uncheck_use_location_in_conversion
    uncheck "demo_use_location_in_conversion"
  end

  it "toggling them off" do
    @demo.update_attributes(use_location_in_conversion: true)
    visit edit_admin_demo_path(@demo, as: an_admin)
    uncheck_use_location_in_conversion
    click_button "Update Game"
    
    @demo.reload.use_location_in_conversion.should be_false
  end

  it "toggling them on" do
    @demo.use_location_in_conversion.should be_false

    visit edit_admin_demo_path(@demo, as: an_admin)
    check_use_location_in_conversion
    click_button "Update Game"
    
    @demo.reload.use_location_in_conversion.should be_true
  end
end
