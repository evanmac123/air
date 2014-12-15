require "spec_helper"

describe "tiles/_multiple_choice_answers.html.erb" do
  context "when the tile in question is completed by the current user, and not a preview" do
    let(:tile) { FactoryGirl.build_stubbed(:multiple_choice_tile, multiple_choice_answers: %w(Zero One)) }
    let(:user) { FactoryGirl.build_stubbed(:user) }
    let(:tile_completion) { FactoryGirl.build_stubbed(:tile_completion, answer_index: 0) }

    let(:presenter) { FullSizeTilePresenter.new(tile, user, false, []) }

    before do
      presenter.stubs(:non_preview_of_completed_tile).returns(true)
      presenter.stubs(:user_tile_completion).returns(tile_completion)

      render "tiles/multiple_choice_answers", tile: presenter
    end

    context "and this answer is the one used to complete" do
      it "should render a clicked right answer" do
        rendered.should have_css('.clicked_right_answer', text: 'Zero')
      end
    end

    context "but this answer is not the one used to complete" do
      it "should render a nerfed answer" do
        rendered.should have_css('.nerfed_answer', text: 'One')
      end
    end
  end
end
