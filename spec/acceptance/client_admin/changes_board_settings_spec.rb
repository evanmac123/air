require 'acceptance/acceptance_helper'

feature "Client Admin Changes Board Settings" do
  let(:demo) { FactoryGirl.create :demo, name: "Board 1", email: "board1@ourairbo.com" }
  let(:client_admin) { FactoryGirl.create(:client_admin, demo: demo)}

  def board_name_form
    "#edit_board_name"
  end

  def board_logo_form
    "#edit_board_logo"
  end

  def board_email_form
    "#edit_board_email"
  end

  def clear_link
    page.find(".clear_form")
  end

  def wrong_format_message
    "Sorry that doesn't look like an image file. Please use a " +
    "file with the extension .jpg, .jpeg, .gif, .bmp or .png."
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

  context "board logo form" do
    before(:each) do
      visit client_admin_board_settings_path(as: client_admin)
    end

    it "should show airbo logo by default" do
      expect_default_logo_in_header
    end

    it "should update logo", js: true do
      within board_logo_form do
        attach_tile "demo[logo]", logo_fixture_path('tasty.jpg')
        click_button "Update"
      end

      demo.reload.logo_file_name.should == 'tasty.jpg'
      expect_logo_in_header 'tasty.png'
    end

    it "should show error message if wrong file format", js: true do
      within board_logo_form do
        attach_tile "demo[logo]", logo_fixture_path('not_an_image.txt')
        click_button "Update"
      end

      expect_content wrong_format_message

      expect_default_logo_in_header
      demo.reload.logo.url.should =~ /logo.png/
    end

    it "sholud set default logo by clear link", js: true do
      demo.logo = File.open(Rails.root.join "spec/support/fixtures/logos/tasty.jpg")
      demo.save
      visit client_admin_board_settings_path(as: client_admin)
      expect_logo_in_header 'tasty.png'

      within board_logo_form do
        clear_link.click
      end

      expect_default_logo_in_header
      demo.reload.logo.url.should =~ /logo.png/
    end
  end

  context "board email form" do
    before(:each) do
      (2..4).to_a.each do |i|
        new_demo = FactoryGirl.create :demo, email: "board#{i}@ourairbo.com"
      end

      visit client_admin_board_settings_path(as: client_admin)
    end

    it "should update email address if it's available", js: true do
      within board_email_form do
        fill_in "Email Address", with: "board10"
        click_button "Update"
      end

      demo.reload.email.should == "board10@ourairbo.com"
    end

    it "should not update email address if it's not available", js: true do
      within board_email_form do
        fill_in "Email Address", with: "board2"
        click_button "Update"
      end

      expect_content "Sorry, that email address is already taken."
      demo.reload.email.should == "board1@ourairbo.com"
    end

    it "should clear form by clear link", js: true do
      within board_email_form do
        fill_in "Email Address", with: "board2 4"
        clear_link.click
      end

      find_field('Email Address').value.should eq 'board1'
    end
  end
end