require 'acceptance/acceptance_helper'

feature "interacts with a tile from the explore-preview page" do
  include GuestUserConversionHelpers
  include WaitForAjax
  include SignUpModalHelpers
  include TilePreviewHelpers

  def show_register_form?
    @user.nil? || @user.class == GuestUser
  end

  let (:creator) {FactoryGirl.create(:client_admin, name: "Charlotte McTilecreator")}
  let (:actor) {FactoryGirl.create(:client_admin, name: "Joe Copier")}
  let (:last_actor) {FactoryGirl.create(:client_admin, name: "John Lastactor")}
  let (:second_actor) {FactoryGirl.create(:client_admin, name: "Suzanne von Secondactor")}

  shared_examples_for 'copies tile' do
    scenario "by clicking the proper link", js: true do
      click_copy_button

      expect(Tile.count).to eq(2)

      expect_tile_copied(@original_tile, @user)
    end

    context "when the tile has no creator", js: true do
      before do
        @original_tile.update_attributes(creator: nil)
      end

      it "should work", js: true do
        click_copy_button

        expect(Tile.count).to eq(2)

        expect_tile_copied(@original_tile, @user)
      end
    end

    scenario "should show a helpful message after copying", js: true do
      click_copy_button

      page.find('.tile_copied_lightbox', visible: true)

      expect_content(post_copy_copy)
    end

    scenario "works if no creator is set", js: true do
      @original_tile.update_attributes(creator: nil)

      click_copy_button

      page.find('.tile_copied_lightbox', visible: true)

      expect_content(post_copy_copy)
    end
  end

  context "as Client admin", js: true, wonky: true do
    before do
      pending "Fails intermittently" 
      @original_tile = FactoryGirl.create(:multiple_choice_tile, :copyable, creator: creator, demo: creator.demo)

      @user = FactoryGirl.create(:client_admin, name: "Lucille Adminsky")
      visit explore_tile_preview_path(@original_tile, as: @user)
    end

    it_should_behave_like "copies tile"
  end

  context "as User", js: true do
    before do
      @original_tile = FactoryGirl.create(:multiple_choice_tile, :copyable, creator: creator, demo: creator.demo)

      @user = FactoryGirl.create(:claimed_user)

      visit explore_tile_preview_path(@original_tile, as: @user)
    end

    it "should let user copy tile" do
      expect(page).to have_link("Copy to Board")
    end
  end

  context "as Nobody", js: true  do
    before do
      UserIntro.any_instance.stubs(:explore_intro_seen).returns(true)
      @original_tile = FactoryGirl.create(:multiple_choice_tile, :copyable, creator: creator, demo: creator.demo)

      visit explore_tile_preview_path(@original_tile, as: nil)
    end

    context "when I click on Explore" do
      it "should prompt me to sign up" do
        expect(page.has_button?("Create Free Account")).to eq(false)

        page.find("a.see_airbo", match: :first).click

        expect(page.has_button?("Create Free Account")).to eq(true)
      end
    end

    context "when I click on See How It Works" do
      it "should prompt me to sign up" do
        expect(page).to have_no_content("Create an account to interact with this tile and many others.")

        page.all("a.see_airbo").last.click

        expect(page).to have_content("Create an account to interact with this tile and many others.")
      end
    end

    context "when I click on a category tag" do
      it "should prompt me to sign up" do
        expect(page.has_button?("Create Free Account")).to eq(false)

        page.find("a.tag", match: :first).click

        expect(page.has_button?("Create Free Account")).to eq(true)
      end
    end

    context "when I click on a wrong answer" do
      it "should tell me I'm wrong" do
        expect(page).to have_no_content("Sorry, that's not it. Try again!")

        page.find("a.wrong_multiple_choice_answer", match: :first).click

        expect(page).to have_content("Sorry, that's not it. Try again!")
      end
    end

    context "when I click on a right answer" do
      it "should tell me I'm right" do
        expect(page).to have_no_content("Correct!")

        page.find("a.right_multiple_choice_answer", match: :first).click

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

    context "when I click on Explore" do
      it "should prompt me to sign up" do
        expect(page.has_button?("Create Free Account")).to eq(false)

        page.find("a.see_airbo", match: :first).click

        expect(page.has_button?("Create Free Account")).to eq(true)
      end
    end

    context "when I click on See How It Works" do
      it "should prompt me to sign up" do
        expect(page).to have_no_content("Create an account to interact with this tile and many others.")

        page.all("a.see_airbo").last.click

        expect(page).to have_content("Create an account to interact with this tile and many others.")
      end
    end

    context "when I click on a category tag" do
      it "should prompt me to sign up" do
        expect(page.has_button?("Create Free Account")).to eq(false)

        page.find("a.tag", match: :first).click

        expect(page.has_button?("Create Free Account")).to eq(true)
      end
    end

    context "when I click on a wrong answer" do
      it "should tell me I'm wrong" do
        expect(page).to have_no_content("Sorry, that's not it. Try again!")

        page.find("a.wrong_multiple_choice_answer", match: :first).click

        expect(page).to have_content("Sorry, that's not it. Try again!")
      end
    end

    context "when I click on a right answer" do
      it "should tell me I'm right" do
        expect(page).to have_no_content("Correct!")

        page.find("a.right_multiple_choice_answer", match: :first).click

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
