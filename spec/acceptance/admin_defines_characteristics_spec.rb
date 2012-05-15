require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "Admin Defines Characteristics" do

  def expect_characteristic_row(name, description, allowed_values)
    name_cell = page.find(:css, "td", :text => name)
    name_cell.should be_present

    characteristic_row = page.find(:xpath, name_cell.path + "/..")

    characteristic_row.find(:css, "td", :text => description).should be_present

    allowed_values.each {|allowed_value| characteristic_row.find(:css, "li", :text => allowed_value)}.should be_present
  end

  def expect_allowed_value_text_field(expected_value)
    page.find(:css, %{[@name="characteristic[allowed_values][]"][@value="#{expected_value}"]}).should be_present 
  end

  before(:each) do
    signin_as_admin

    @demo = FactoryGirl.create :demo
    @agnostic_characteristic = FactoryGirl.create :characteristic, :name => "Favorite pill", :description => "what kind of pill you like", :allowed_values => %w(Viagra Clonozepam Warfarin)
    @characteristic_1 = FactoryGirl.create :demo_specific_characteristic, :demo => @demo, :name => "Cheese preference", :description => "what sort of cheese does you best", :allowed_values => %w(Stinky Extra-Stinky)
    @characteristic_2 = FactoryGirl.create :demo_specific_characteristic, :name => "Cake or death", :description => "A simple question really", :allowed_values => %w(Cake Death)
    
    @characteristic_2.demo.should_not == @demo
  end

  context "For demo-agnostic characteristics" do
    before(:each) do
      visit admin_characteristics_path
    end

    scenario "admin sees existing demo-agnostic characteristics" do
      expect_characteristic_row 'Favorite pill', 'what kind of pill you like', %w(Viagra Clonozepam Warfarin)

      expect_no_content "Cheese preference"
      expect_no_content "Cake or death"
    end

    scenario "admin creates new characteristic", :js => true do
      signin_as_admin
      visit admin_characteristics_path

      fill_in "characteristic[name]", :with => "T-shirt size"
      fill_in "characteristic[description]", :with => "The size t-shirt you want if you win"
      fill_in "characteristic[allowed_values][]", :with => "S"

      # Should do the Right Thing even if the admin is sloppy about which
      # allowed value fields they fill in, i.e. blank ones should get skipped
      # over silently.
      
      10.times{ click_button "More allowed values" }
      allowed_value_fields = page.all('input[@name="characteristic[allowed_values][]"]')

      allowed_value_fields[3].set("M")
      allowed_value_fields[7].set("L")
      allowed_value_fields[9].set("XL")
      click_button "characteristic_submit"

      expect_content 'Characteristic "T-shirt size" created'
      expect_characteristic_row 'T-shirt size', "The size t-shirt you want if you win", %w(S M L XL)
    end

    scenario "admin edits existing characteristic", :js => true do
      signin_as_admin
      visit admin_characteristics_path
      click_link "Edit"

      expect_allowed_value_text_field 'Viagra'
      expect_allowed_value_text_field 'Clonozepam'
      expect_allowed_value_text_field 'Warfarin'

      fill_in "characteristic[name]", :with => "Pants size"
      fill_in "characteristic[description]", :with => "How big are your pants?"

      # Overwrite some allowed values, blank out some others, add some new ones, whee.
      allowed_value_fields = page.all('input[@name="characteristic[allowed_values][]"]')
      allowed_value_fields.length.should == 3
     
      allowed_value_fields[1].set('')
      allowed_value_fields[2].set('cheese whiz')

      3.times{ click_button "More allowed values" }
      allowed_value_fields = page.all('input[@name="characteristic[allowed_values][]"]')

      allowed_value_fields[4].set('oh yeah')
      click_button 'Update Characteristic'

      expect_characteristic_row 'Pants size', "How big are your pants?", ["Viagra", "cheese whiz", "oh yeah"]
      expect_no_content "Favorite pill"
      expect_no_content "what kind of pill you like"    
      expect_no_content 'Clonozepam'
      expect_no_content 'Warfarin'
    end

    scenario "admin destroys existing characteristic" do
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
    before do
      visit admin_demo_characteristics_path(@demo)
    end

    scenario "admin sees characteristics for just that demo" do
      expect_characteristic_row "Cheese preference", "what sort of cheese does you best", %w(Stinky Extra-Stinky)
      expect_no_content "Favorite pill"
      expect_no_content "Cake or death"
    end

    scenario "new characteristic should be created into that demo" do
      fill_in "characteristic[name]", :with => "T-shirt size"
      fill_in "characteristic[description]", :with => "The size t-shirt you want if you win"
      fill_in "characteristic[allowed_values][]", :with => "S"

      click_button "characteristic_submit"

      should_be_on admin_demo_characteristics_path(@demo)

      expect_content 'Characteristic "T-shirt size" created'
      expect_characteristic_row "Cheese preference", "what sort of cheese does you best", %w(Stinky Extra-Stinky)
      expect_characteristic_row 'T-shirt size', "The size t-shirt you want if you win", %w(S)
      expect_no_content "Favorite pill"
      expect_no_content "Cake or death"
    end

    scenario "update should return to the right place" do
      click_link "Edit"
      fill_in "characteristic[name]", :with => "Goat preference"
      fill_in "characteristic[description]", :with => "What kind of goat do you want?"
      click_button "Update Characteristic"

      should_be_on admin_demo_characteristics_path(@demo)

      expect_characteristic_row "Goat preference", "What kind of goat do you want?", %w(Stinky Extra-Stinky)
      expect_no_content "Favorite pill"
      expect_no_content "Cake or death"
    end

    scenario "destroy should return to the right place" do
      click_button "Destroy"
      should_be_on admin_demo_characteristics_path(@demo)
      expect_no_content "Cheese preference"
    end
  end
end
