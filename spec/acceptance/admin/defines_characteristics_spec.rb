require 'acceptance/acceptance_helper'

feature "Admin Defines Characteristics" do

  def expect_characteristic_row(name, description, datatype, allowed_values=nil)
    page.find(:css, "td.characteristic-name", :text => name).should be_present
    page.find(:css, "td", :text => description).should be_present
  end

  def expect_allowed_value_text_field(expected_value)
    page.find(:css, %{[name="characteristic[allowed_values][]"][value="#{expected_value}"]}).should be_present
  end

  # We have all this nonsense because before(:each) and :js=>true do not play well together.
  def set_up_demo_and_characteristics
    @demo = FactoryGirl.create :demo
    @agnostic_characteristic = FactoryGirl.create :characteristic, :name => "Favorite pill", :description => "what kind of pill you like", :allowed_values => %w(Viagra Clonozepam Warfarin)
    @characteristic_1 = FactoryGirl.create :characteristic, :demo_specific, :demo => @demo, :name => "Cheese preference", :description => "what sort of cheese does you best", :allowed_values => %w(Stinky Extra-Smelly)
    @characteristic_2 = FactoryGirl.create :characteristic, :demo_specific, :name => "Cake or death", :description => "A simple question really", :allowed_values => %w(Cake Death)

    @characteristic_2.demo.should_not == @demo
  end

  def click_edit_link
    within('.admin') {click_link "Edit"}
    # click_link "Edit"
  end

  context "For demo-agnostic characteristics" do
    it "admin sees existing demo-agnostic characteristics" do
      set_up_demo_and_characteristics
      visit admin_characteristics_path(as: an_admin)

      expect_characteristic_row 'Favorite pill', 'what kind of pill you like', 'Discrete', %w(Viagra Clonozepam Warfarin)

      expect_no_content "Cheese preference"
      expect_no_content "Cake or death"
    end

    it "admin creates new characteristic", :js => true do
      set_up_demo_and_characteristics
      visit admin_characteristics_path(as: an_admin)

      fill_in "characteristic[name]", with: "T-shirt size"
      fill_in "characteristic[description]", :with => "The size t-shirt you want if you win"
      fill_in "characteristic[allowed_values][]", :with => "Small"

      # Should do the Right Thing even if the admin is sloppy about which allowed
      # value fields they fill in, i.e. blank ones should get skipped over silently.

      10.times{ click_button "More allowed values" }
      allowed_value_fields = page.all('input[name="characteristic[allowed_values][]"]')

      allowed_value_fields[1].set("Medium")
      allowed_value_fields[3].set("Large")
      click_button "Create Characteristic"
      expect_content 'Characteristic "T-shirt size" created'
      expect_characteristic_row 'T-shirt size', "The size t-shirt you want if you win", 'Discrete', %w(Small Medium Large)
    end

    it "admin edits existing characteristic", :js => true do
      set_up_demo_and_characteristics
      visit admin_characteristics_path(as: an_admin)
      click_edit_link

      expect_allowed_value_text_field 'Viagra'
      expect_allowed_value_text_field 'Clonozepam'
      expect_allowed_value_text_field 'Warfarin'

      fill_in "characteristic[name]", :with => "Pants size"
      fill_in "characteristic[description]", :with => "How big are your pants?"

      # Overwrite some allowed values, blank out some others, add some new ones, whee.
      allowed_value_fields = page.all('input[name="characteristic[allowed_values][]"]')
      allowed_value_fields.length.should == 3

      allowed_value_fields[1].set('   ')
      allowed_value_fields[2].set('cheese whiz')

      3.times{ click_button "More allowed values" }
      allowed_value_fields = page.all('input[name="characteristic[allowed_values][]"]')

      allowed_value_fields[4].set('oh yeah')
      click_button 'Update Characteristic'

      expect_characteristic_row 'Pants size', "How big are your pants?", 'Discrete', ["Viagra", "cheese whiz", "oh yeah"]
      expect_no_content "Favorite pill"
      expect_no_content "what kind of pill you like"
      expect_no_content 'Clonozepam'
      expect_no_content 'Warfarin'
    end

    it "admin destroys existing characteristic" do
      set_up_demo_and_characteristics
      visit admin_characteristics_path(as: an_admin)

      click_button "Destroy"
      should_be_on admin_characteristics_path
      expect_no_content "Favorite pill"
      expect_no_content "what kind of pill you like"
      expect_no_content 'Viagra'
      expect_no_content 'Clonozepam'
      expect_no_content 'Warfarin'
    end
  end

  context "For demo-specific characteristics" do
    it "admin sees characteristics for just that demo" do
      set_up_demo_and_characteristics
      visit admin_demo_characteristics_path(@demo, as: an_admin)
      expect_characteristic_row "Cheese preference", "what sort of cheese does you best", 'Discrete', %w(Stinky Extra-Smelly)
      expect_no_content "Favorite pill"
      expect_no_content "Cake or death"
    end

    it "new characteristic should be created into that demo" do
      set_up_demo_and_characteristics
      visit admin_demo_characteristics_path(@demo, as: an_admin)

      fill_in "characteristic[name]", :with => "T-shirt size"
      fill_in "characteristic[description]", :with => "The size t-shirt you want if you win"
      fill_in "characteristic[allowed_values][]", :with => "Small"

      click_button "Create Characteristic"

      should_be_on admin_demo_characteristics_path(@demo)

      expect_content 'Characteristic "T-shirt size" created'
      expect_characteristic_row "Cheese preference", "what sort of cheese does you best", 'Discrete', %w(Stinky Extra-Smelly)
      expect_characteristic_row 'T-shirt size', "The size t-shirt you want if you win", 'Discrete', %w(Small)
      expect_no_content "Favorite pill"
      expect_no_content "Cake or death"
    end

    it "update should return to the right place" do
      set_up_demo_and_characteristics
      visit admin_demo_characteristics_path(@demo, as: an_admin)

      click_edit_link
      fill_in "characteristic[name]", :with => "Goat preference"
      fill_in "characteristic[description]", :with => "What kind of goat do you want?"
      click_button "Update Characteristic"

      should_be_on admin_demo_characteristics_path(@demo)

      expect_characteristic_row "Goat preference", "What kind of goat do you want?", 'Discrete', %w(Stinky Extra-Smelly)
      expect_no_content "Favorite pill"
      expect_no_content "Cake or death"
    end

    it "destroy should return to the right place" do
      set_up_demo_and_characteristics
      visit admin_demo_characteristics_path(@demo, as: an_admin)

      click_button "Destroy"
      should_be_on admin_demo_characteristics_path(@demo)
      expect_no_content "Cheese preference"
    end
  end

  context "with type information" do
    it "should remember the type", :js => true do
      set_up_demo_and_characteristics
      visit admin_characteristics_path(as: an_admin)

      fill_in "characteristic[name]", :with => "Some number"
      fill_in "characteristic[description]", :with => "Some numerical type of field"
      select "Number", :from => "characteristic[datatype]"

      click_button "Create Characteristic"
      should_be_on admin_characteristics_path

      expect_characteristic_row "Some number", "Some numerical type of field", 'Number'
    end

    it "should display allowable value fields only for discrete characteristics", :js => true do
      set_up_demo_and_characteristics
      visit admin_characteristics_path(as: an_admin)

      select "Number", :from => "characteristic[datatype]"
      page.all('input[name="characteristic[allowed_values][]"]').select(&:visible?).should be_empty

      select "Date", :from => "characteristic[datatype]"
      page.all('input[name="characteristic[allowed_values][]"]').select(&:visible?).should be_empty

      select "Boolean", :from => "characteristic[datatype]"
      page.all('input[name="characteristic[allowed_values][]"]').select(&:visible?).should be_empty

      select "Time", :from => "characteristic[datatype]"
      page.all('input[name="characteristic[allowed_values][]"]').select(&:visible?).should be_empty

      # And bring that field back
      select "Discrete", :from => "characteristic[datatype]"
      page.all('input[name="characteristic[allowed_values][]"]').select(&:visible?).should_not be_empty
    end
  end
end
