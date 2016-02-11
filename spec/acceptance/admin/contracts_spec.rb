require 'acceptance/acceptance_helper'
feature "Contracts", js:true do
  before do
    @org = FactoryGirl.create(:organization, :complete)
  end

  context "as primary" do
    before do
      begin_contract
      create_as_primary
    end
    scenario "creates a primary contract with arr for organization" do
      add_arr
      click_button "Submit"
      expect_sucess 
    end

    scenario "creates a primary contract with mrr for organization" do
      add_mrr
      click_button "Submit"
      expect_sucess 
    end
  end

  context "as upgrade" do
    before do
      @parent = FactoryGirl.create(:contract, :complete, organization: @org)
    end
    scenario "creates a upgrade contract with mrr for organization" do
      begin_contract

      page.find("tr", text: @parent.name).click
      click_link "Add Upgrade"
      fill_in_main_contract_details
      add_arr
      click_button "Submit"
      expect_sucess 
    end
  end



  def expect_sucess
   expect_content "Request completed succesfully"
  end

  def begin_contract
    visit admin_path(as: an_admin)
    click_link "Manage Organizations"
    page.find("tr", text: @org.name).click
  end

  def create_as_primary
    click_link "Add New Contract"
    fill_in_main_contract_details
  end

  def create_as_upgrade
  end

  def fill_in_main_contract_details
    choose "Engage"
    fill_in "contract_name", with: "Contract 1"
    fill_in "contract_start_date", with: "2015-01-01"
    fill_in "contract_end_date", with: "2015-12-31"
    fill_in "contract_max_users", with: 5000
    fill_in "contract_amt_booked", with: 50000
    fill_in "contract_date_booked", with: "2015-01-01"
    fill_in "contract_notes", with: "This is a notable account"
    fill_in "contract_term", with: 12
  end

 def add_arr
   choose "Annual"
   fill_in "contract_arr", with: 10000 
 end

 def add_mrr
   choose "Monthly"
   fill_in "contract_mrr", with: 1000
 end


end
