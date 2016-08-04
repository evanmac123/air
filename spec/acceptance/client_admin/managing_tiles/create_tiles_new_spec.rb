require 'acceptance/acceptance_helper'
feature "Client admin creates tiles", js: true do

  context "new tile" do
    let (:client_admin) { FactoryGirl.create(:client_admin)}
    let (:demo)         { client_admin.demo }

    before do
      visit client_admin_tiles_path(as: client_admin)
    end
    scenario "Creates new tile", js: true do
      page.find("#add_new_tile").trigger("click")
      fill_in_tile_form_entries
      click_create_button
      within ".viewer" do
        expect(page).to  have_content "by Society"
        expect(page).to  have_content "Ten pounds of cheese"
        expect(page).to  have_content "Ten pounds of cheese. Yes? Or no?"
        expect(page).to  have_content "Who rules?"
      end

      expect(page).to have_selector(".tile_multiple_choice_answer a.right_multiple_choice_answer", text: "Hipster")
      expect(page).to have_selector("#tile_point_value", text: "18")
    end

  end

  context "existing tile" do
    let(:edit_text){"baz"}
    let(:points){"10"}

    before do
      @tile = FactoryGirl.create :multiple_choice_tile
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
        expect(page).to  have_content "Which of the following comes out of a bird?"
        expect(page).to  have_content "Ham"
        expect(page).to  have_content "Eggs"
        expect(page).to  have_content "A V8 Buick"
      end
    end

    scenario  "edit all tile fields" do

      fill_in_tile_form_entries edit_text: edit_text, points: points
      click_create_button


      within ".viewer" do
        expect(page).to  have_content "by Society#{edit_text}"
        expect(page).to  have_content "Ten pounds of cheese#{edit_text}"
        expect(page).to  have_content "Ten pounds of cheese. Yes? Or no?#{edit_text}"
        expect(page).to  have_content "Who rules?#{edit_text}"
      end

      expect(page).to have_selector("a.right_multiple_choice_answer", text: "Hipster#{edit_text}")
      expect(page).to have_selector("#tile_point_value", text: points)
    end
  end


  def click_create_button

    page.find("#new_tile_builder_form .submit_tile_form").trigger("click")
  end

  def fill_in_tile_form_entries options = {}
    click_answer = options[:click_answer] || 1
    question_type = options[:question_type] || Tile::QUIZ
    question_subtype = options[:question_subtype] || Tile::MULTIPLE_CHOICE
    edit_text = options[:edit_text] || "foobar"
    points = options[:points] || "18"


    choose_question_type_and_subtype question_type, question_subtype
    fake_upload_image img_file1

    fill_in_image_credit "by Society#{edit_text}"
    page.find("#tile_builder_form_headline").set("Ten pounds of cheese#{edit_text}")
    page.find("#tile_supporting_content").native.send_key("Ten pounds of cheese. Yes? Or no?#{edit_text}")
    fill_in_question "Who rules?#{edit_text}"
    2.times {click_add_answer}
    fill_in_answer_field 0, "Me#{edit_text}"
    fill_in_answer_field 1, "You#{edit_text}"
    fill_in_answer_field 2, "Hipster#{edit_text}"
    click_answer.times { select_correct_answer 2 } if question_type == Tile::QUIZ
    fill_in_points points
  end

end
