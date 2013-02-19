require 'acceptance/acceptance_helper'

feature "Admin Defines Characteristics" do

  def expect_characteristic_row(name, description, datatype, allowed_values=nil)
    page.find(:css, "td.characteristic-name", :text => name)

    # Have to do a little screwing around because of Capy2. (Found multiple "<td>Discrete</td>" => Need to be specific)
    # The cool thing is that once you find the 'description' column, you know the 'type' should be the adjoining one!
    # Specifically, the 'description' column's xpath is: '/html/body/div[3]/div/table/tbody/tr[3]/td[2]'
    # Which means the correct 'type' column is just that, but with a 'td[3]' at the end.
    #
    # Similarly, down below (in the 'allowed_values' block), the correct 'allowed values' column has a 'td[4]' at the end
    description_column = page.find(:css, "td", :text => description)
    description_column.should be_present

    description_column_path = description_column.path
    description_column_path[-2] = (description_column_path[-2].to_i + 1).to_s

    page.find(:xpath, description_column_path, text: datatype).should be_present

    if allowed_values.present?
      description_column_path[-2] = (description_column_path[-2].to_i + 1).to_s
      allowed_values.each {|allowed_value| page.find(:xpath, description_column_path).find(:css, "li", :text => allowed_value)}.should be_present
    end
  end

  def expect_allowed_value_text_field(expected_value)
    page.find(:css, %{[@name="characteristic[allowed_values][]"][@value="#{expected_value}"]}).should be_present 
  end

  # We have all this nonsense because before(:each) and :js=>true do not play well together.
  def set_up_demo_and_characteristics
    @demo = FactoryGirl.create :demo
    @agnostic_characteristic = FactoryGirl.create :characteristic, :name => "Favorite pill", :description => "what kind of pill you like", :allowed_values => %w(Viagra Clonozepam Warfarin)
    @characteristic_1 = FactoryGirl.create :characteristic, :demo_specific, :demo => @demo, :name => "Cheese preference", :description => "what sort of cheese does you best", :allowed_values => %w(Stinky Extra-Smelly)
    @characteristic_2 = FactoryGirl.create :characteristic, :demo_specific, :name => "Cake or death", :description => "A simple question really", :allowed_values => %w(Cake Death)
    
    @characteristic_2.demo.should_not == @demo
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

      fill_in "characteristic[name]", :with => "T-shirt size"
      fill_in "characteristic[description]", :with => "The size t-shirt you want if you win"
      fill_in "characteristic[allowed_values][]", :with => "S"

      # Should do the Right Thing even if the admin is sloppy about which allowed
      # value fields they fill in, i.e. blank ones should get skipped over silently.
      
      10.times{ click_button "More allowed values" }
      allowed_value_fields = page.all('input[@name="characteristic[allowed_values][]"]')

      allowed_value_fields[1].set("M")
      allowed_value_fields[3].set("L")
      click_button "Create Characteristic"

      expect_content 'Characteristic "T-shirt size" created'
      expect_characteristic_row 'T-shirt size', "The size t-shirt you want if you win", 'Discrete', %w(S M L)
    end

    it "admin edits existing characteristic", :js => true do
      set_up_demo_and_characteristics
      visit admin_characteristics_path(as: an_admin)
      click_link "Edit"

      expect_allowed_value_text_field 'Viagra'
      expect_allowed_value_text_field 'Clonozepam'
      expect_allowed_value_text_field 'Warfarin'

      fill_in "characteristic[name]", :with => "Pants size"
      fill_in "characteristic[description]", :with => "How big are your pants?"

      # Overwrite some allowed values, blank out some others, add some new ones, whee.
      allowed_value_fields = page.all('input[@name="characteristic[allowed_values][]"]')
      allowed_value_fields.length.should == 3
    
      allowed_value_fields[1].set('   ')
      allowed_value_fields[2].set('cheese whiz')

      3.times{ click_button "More allowed values" }
      allowed_value_fields = page.all('input[@name="characteristic[allowed_values][]"]')

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
      fill_in "characteristic[allowed_values][]", :with => "S"

      click_button "Create Characteristic"

      should_be_on admin_demo_characteristics_path(@demo)

      expect_content 'Characteristic "T-shirt size" created'
      expect_characteristic_row "Cheese preference", "what sort of cheese does you best", 'Discrete', %w(Stinky Extra-Smelly)
      expect_characteristic_row 'T-shirt size', "The size t-shirt you want if you win", 'Discrete', %w(S)
      expect_no_content "Favorite pill"
      expect_no_content "Cake or death"
    end

    it "update should return to the right place" do
      set_up_demo_and_characteristics
      visit admin_demo_characteristics_path(@demo, as: an_admin)

      click_link "Edit"
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
      page.all('input[@name="characteristic[allowed_values][]"]').select(&:visible?).should be_empty

      select "Date", :from => "characteristic[datatype]"
      page.all('input[@name="characteristic[allowed_values][]"]').select(&:visible?).should be_empty

      select "Boolean", :from => "characteristic[datatype]"
      page.all('input[@name="characteristic[allowed_values][]"]').select(&:visible?).should be_empty

      select "Time", :from => "characteristic[datatype]"
      page.all('input[@name="characteristic[allowed_values][]"]').select(&:visible?).should be_empty

      # And bring that field back
      select "Discrete", :from => "characteristic[datatype]"
      page.all('input[@name="characteristic[allowed_values][]"]').select(&:visible?).should_not be_empty
    end
  end
end
