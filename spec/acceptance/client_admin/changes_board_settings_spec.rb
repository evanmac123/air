require 'acceptance/acceptance_helper'

feature "Client Admin Changes Board Settings" do
  let(:demo) { FactoryGirl.create :demo, name: "Board 1" }
  let (:client_admin) { FactoryGirl.create(:client_admin, demo: demo)}

  def board_name_form
    "#edit_board_name"
  end

  def clear_link
    page.find(".clear_form")
  end
  
  context "board name form" do
    before(:each) do
      (2..4).to_a.each do |i|
        new_demo = FactoryGirl.create :demo, name: "Board #{i}"
      end

      visit client_admin_board_settings_path(as: client_admin)
    end

    it "should update board name if it's available", js: true do
      within board_name_form do
        fill_in "Board Name", with: "Board 5"
        click_button "Update"
      end

      demo.reload.name.should == "Board 5"
      page.find("#current_board_name").text.should == "Board 5"
    end

    it "should not update board name if it's not available", js: true do
      within board_name_form do
        fill_in "Board Name", with: "Board 4"
        click_button "Update"
      end

      demo.reload.name.should == "Board 1"
      expect_content "Sorry, that board name is already taken."
    end

    it "should clear form by clear link", js: true do
      within board_name_form do
        fill_in "Board Name", with: "Board 4"
        clear_link.click
      end

      find_field('Board Name').value.should eq 'Board 1'
    end
  end
end