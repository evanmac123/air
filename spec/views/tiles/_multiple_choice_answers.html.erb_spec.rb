require "spec_helper"

describe "tiles/_multiple_choice_answers.html.erb" do
  context "when the tile in question is completed by the current user, and not a preview" do

    before do
      tile = FactoryGirl.create(:multiple_choice_tile, multiple_choice_answers: %w(Zero One))
      user = FactoryGirl.create(:user) 
      FactoryGirl.create(:tile_completion, tile: tile, user: user, answer_index: 0) 

      view.stubs(:current_user).returns(user)
      render partial: "tiles/multiple_choice_answers", locals: {tile: tile, is_preview: false}
    end

    context "and this answer is the one used to complete" do
      it "should render a clicked right answer" do
        expect(rendered).to have_css('.clicked_right_answer', text: 'Zero')
      end
    end

    context "but this answer is not the one used to complete" do
      it "should render a nerfed answer" do
        expect(rendered).to have_css('.nerfed_answer', text: 'One')
      end
    end
  end
end
