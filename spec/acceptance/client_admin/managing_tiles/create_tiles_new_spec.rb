require 'acceptance/acceptance_helper'
feature "Client admin creates tiles", js: true do

  context "new tile" do
    let (:client_admin) { FactoryGirl.create(:client_admin)}
    let (:demo)         { client_admin.demo }

    before do
      visit client_admin_tiles_path(as: client_admin)
    end

    scenario "Creates new tile", js: true do
      click_link "Add New Tile"
      fill_in_tile_form_entries edit_text: "baz", points: "10"
      click_create_button
      page.find(".viewer")

      within ".viewer" do
        expect(page).to  have_content "by Society"
        expect(page).to  have_content "Ten pounds of cheese"
        expect(page).to  have_content "Ten pounds of cheese. Yes? Or no?"
        expect(page).to  have_content "Who rules?"
      end

      expect(page).to have_selector("a.multiple-choice-answer.correct ", text: "Youbaz")
      expect(page).to have_selector("#tile_point_value", text: "10")
    end

    scenario "Creates new optional free reponse tile", js: true do
      click_link "Add New Tile"
      choose_question_type_and_subtype Tile::SURVEY, Tile::MULTIPLE_CHOICE
      expect(page).to have_content "Allow Free Response"
    end

    scenario "Creates new free reponse tile", js: true do
      click_link "Add New Tile"
      choose_question_type_and_subtype Tile::SURVEY,"free_response" 
      expect(page).to have_css ".js-free-form-response.free-text-entry"
    end

    context "autosave" do
      scenario "create with only headline" do
        click_link "Add New Tile"
        page.find("#tile_headline").set("Ten pounds of cheese")
        page.find(".close-reveal-modal").click
        within ".tile_container.unfinished" do
          expect(page).to  have_content "Ten pounds of cheese"
        end
      end

      scenario "creates only one tile when  " do
        pending "unable to simulate this scenario in acceptance test"

        #NOTE 
        #this test attempts to simulate a bug #708 where two tiles 
        # are created if the user uploads an image and quickly causes blur 
        # and focus events on the supporting content field. 
        # leaving it here as pending for future documentation
        
        #NOTE in ordr for it to be ignored by spec runner the expection is wrong
        #on purpose

        click_link "Add New Tile"
        content = page.find(:css, "#supporting_content_editor", visible: false)
        headline = page.find("#tile_headline")
        fake_upload_image img_file1

        content.trigger("focus")
        content.set("This")
        headline.trigger("focus")
        headline.set("Ten pounds of cheese")
        content.trigger("focus")
        content.set("that")
        headline.trigger("focus")
        page.find(".close-reveal-modal").click
        within ".tile_container.draft" do
          expect(page).to  have_css(".tile_thumbnail", count: 2)
        end
      end

      pending "create with only image" do
        click_link "Add New Tile"
        fake_upload_image img_file1
        page.find(".close-reveal-modal").click
        page.find(".tile_container.unfinished")
        within ".tile_container.unfinished" do
          expect(page).to  have_content "Incomplete"
        end
      end
    end
  end

  context "existing tile" do
    let(:edit_text){"baz"}
    let(:points){"10"}

    before do
      @tile = FactoryGirl.create :multiple_choice_tile, question_type: "survey", question_subtype: "multiple_choice"
      @client_admin = FactoryGirl.create(:client_admin, demo: @tile.demo)
      visit client_admin_tiles_path(as: @client_admin)
      within "#single-tile-#{@tile.id}" do
        page.find(".tile-wrapper").hover
        page.find("li.edit_button a").click
      end
    end

    scenario "check tile content in form fields" do
      within ".new_tile_builder_form" do
        expect(page).to  have_content "This is some extra text by the tile"
        expect(page).to  have_field "tile_question", with: "Which of the following comes out of a bird?"
        expect(page).to  have_content "Ham"
        expect(page).to  have_content "Eggs"
        expect(page).to  have_content "A V8 Buick"
      end
    end

    scenario  "edit all tile fields" do

      fill_in_tile_form_entries edit_text: edit_text, points: points
      select_correct_answer 0 
      click_create_button

      within ".viewer" do
        expect(page).to  have_content "by Society#{edit_text}"
        expect(page).to  have_content "Ten pounds of cheese#{edit_text}"
        expect(page).to  have_content "Ten pounds of cheese. Yes? Or no?#{edit_text}"
        expect(page).to  have_content "Who rules?#{edit_text}"
      end
      expect(page).to have_selector("a.multiple-choice-answer.correct", text: "Me#{edit_text}")
      expect(page).to have_selector("#tile_point_value", text: points)
    end
  end


  def click_create_button
    page.find(".submit_tile_form").click
  end

  def fill_in_tile_form_entries options = {}
    question_type = options[:question_type] || Tile::QUIZ.downcase
    question_subtype = options[:question_subtype] || Tile::MULTIPLE_CHOICE
    edit_text = options[:edit_text] || "foobar"
    points = options[:points] || "18"


    choose_question_type_and_subtype question_type, question_subtype
    fake_upload_image img_file1

    fill_in_image_credit "by Society#{edit_text}"
    page.find("#tile_headline").set("Ten pounds of cheese#{edit_text}")
    el = page.find(:css, "#supporting_content_editor", visible: false)
    el.set("Ten pounds of cheese. Yes? Or no?#{edit_text}")
    fill_in_question "Who rules?#{edit_text}"
    fill_in_answer_field 0, "Me#{edit_text}"
    fill_in_answer_field 1, "You#{edit_text}"
    select_correct_answer 1
    fill_in_points points
  end

end
