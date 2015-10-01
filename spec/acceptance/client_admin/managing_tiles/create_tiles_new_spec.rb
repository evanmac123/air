require 'acceptance/acceptance_helper'
feature "Client admin creates tiles", js: true do
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
      page.should have_content "by Society"
      page.should have_content "Ten pounds of cheese"
      page.should have_content "Ten pounds of cheese. Yes? Or no?"
      page.should have_content "Who rules?"
      page.should have_content "http://www.google.com/foobar"
    end

    page.should have_selector(".tile_multiple_choice_answer a.right_multiple_choice_answer", text: "Hipster")
    page.should have_selector("#tile_point_value", text: "18")
  end

  def click_create_button
    page.find("input[type=submit][value='Save tile']").trigger("click")
  end

  def fill_in_tile_form_entries options = {}
    click_answer = options[:click_answer] || 1
    question_type = options[:question_type] || Tile::QUIZ
    question_subtype = options[:question_subtype] || Tile::MULTIPLE_CHOICE
    choose_question_type_and_subtype question_type, question_subtype
    fake_upload_image "cov1.png"
    fill_in_image_credit "by Society"
    page.find("#tile_builder_form_headline").set("Ten pounds of cheese")
    page.find("#tile_supporting_content").native.send_key("Ten pounds of cheese. Yes? Or no?")
    fill_in_question "Who rules?"
    2.times {click_add_answer}
    fill_in_answer_field 0, "Me"
    fill_in_answer_field 1, "You"
    fill_in_answer_field 2, "Hipster"
    click_answer.times { select_correct_answer 2 } if question_type == Tile::QUIZ
    fill_in_points "18"
    fill_in_external_link_field  "http://www.google.com/foobar"
  end

end
