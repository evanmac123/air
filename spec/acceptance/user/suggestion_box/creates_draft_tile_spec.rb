require 'acceptance/acceptance_helper'

feature 'Creates draft tile' do
  let(:user) do
    user = FactoryGirl.create :user, allowed_to_make_tile_suggestions: true
    user.board_memberships.first.update_attribute :allowed_to_make_tile_suggestions, true
    user
  end


  before do
    visit activity_path(as: user)
  end

  it "should open form", js: true do
    submit_tile_btn.click
    within form do
      expect_content form_text
    end
  end

  it "should let them submit tile", js: true do
    submit_tile_btn.click
    fill_in_tile_form_entries
    click_create_button
    within ".viewer" do 
      expect(page).to  have_content "by Society"
      expect(page).to  have_content "Ten pounds of cheese"
      expect(page).to  have_content "Ten pounds of cheese. Yes? Or no?"
      expect(page).to  have_content "Who rules?"
    end
  end


  def submit_tile_btn
    page.find("#submit_tile")
  end

  def form
    page.find("#new_tile_builder_form")
  end

  def form_text
    "Once you submit a Tile, it cannot be edited."
  end


  def fill_in_tile_form_entries options = {}
    click_answer = options[:click_answer] || 1
    question_type = options[:question_type] || Tile::QUIZ
    question_subtype = options[:question_subtype] || Tile::MULTIPLE_CHOICE
    edit_text = options[:edit_text] || "foobar"
    points = options[:points] || "18"
 

    choose_question_type_and_subtype question_type, question_subtype
    fake_upload_image "cov1.png" 

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

  def click_create_button
    page.find("#publish input[type=submit]").trigger("click")
  end
end
