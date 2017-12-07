require 'acceptance/acceptance_helper'

feature "interacts with a tile from the explore-preview page" do
  include GuestUserConversionHelpers
  include SignUpModalHelpers
  include TilePreviewHelpers

  def show_register_form?
    @user.nil? || @user.class == GuestUser
  end

  let (:creator) {FactoryGirl.create(:client_admin, name: "Charlotte McTilecreator")}
  let (:actor) {FactoryGirl.create(:client_admin, name: "Joe Copier")}
  let (:last_actor) {FactoryGirl.create(:client_admin, name: "John Lastactor")}
  let (:second_actor) {FactoryGirl.create(:client_admin, name: "Suzanne von Secondactor")}

  context "as Nobody", js: true  do
    before do
      UserIntro.any_instance.stubs(:explore_intro_seen).returns(true)
      @original_tile = FactoryGirl.create(:multiple_choice_tile, :copyable, creator: creator, demo: creator.demo)

      visit explore_tile_preview_path(@original_tile, as: nil)
    end

    context "when I click on a wrong answer" do
      it "should tell me I'm wrong" do
        expect(page).to have_no_content("Sorry, that's not it. Try again!")

        page.find("a.multiple-choice-answer.incorrect", match: :first).click

        expect(page).to have_content("Sorry, that's not it. Try again!")
      end
    end

    context "when I click on a right answer" do
      it "should tell me I'm right" do
        expect(page).to have_no_content("Correct!")

        page.find("a.multiple-choice-answer.correct", match: :first).click

        expect(page).to have_content("Correct!")
      end
    end

    context "the share link field" do
      it "should have the correct link" do
        within ".share_link_block" do
          link = page.find("input")
          expect(link.value).to eq(current_url)
        end
      end
    end
  end

  context "as Guest", js: true do
    before do

      UserIntro.any_instance.stubs(:explore_intro_seen).returns(true)
      @original_tile = FactoryGirl.create(:multiple_choice_tile, :copyable, creator: creator, demo: creator.demo)
      @user = FactoryGirl.create(:guest_user)

      visit explore_tile_preview_path(@original_tile, as: @user)
    end

    context "when I click on a wrong answer" do
      it "should tell me I'm wrong" do
        expect(page).to have_no_content("Sorry, that's not it. Try again!")

        page.find("a.multiple-choice-answer.incorrect", match: :first).click

        expect(page).to have_content("Sorry, that's not it. Try again!")
      end
    end

    context "when I click on a right answer" do
      it "should tell me I'm right" do
        expect(page).to have_no_content("Correct!")

        page.find("a.multiple-choice-answer.correct", match: :first).click

        expect(page).to have_content("Correct!")
      end
    end

    context "the share link field" do
      it "should have the correct link" do
        within ".share_link_block" do
          link = page.find("input")
          expect(link.value).to eq(current_url.gsub!("?as=guestuser", ""))
        end
      end
    end
  end

  context "as guest for a public tile in a private board" do
    it "should allow the guest to see the tile", js: true do
      private_board = FactoryGirl.create(:demo, is_public: false)
      tile = FactoryGirl.create(:multiple_choice_tile, :copyable, :sharable, demo: private_board)

      visit sharable_tile_path(tile)

      expect_no_content "This board is currently private"
      expect_content tile.headline
    end
  end
end
