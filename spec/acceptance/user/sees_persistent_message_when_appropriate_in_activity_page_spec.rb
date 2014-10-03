require 'acceptance/acceptance_helper'

feature 'Sees persistent message when appropriate in activity page' do
  def default_persistent_message
    "Airbo is an interactive communication tool. Read information and answer questions on the tiles to earn points."  
  end

  before do
    @demo = FactoryGirl.create(:demo, is_public: true)
    @demo.update_attributes(is_public: true)
  end

  def expect_persistent_message_in_get_started_lightbox(message = default_persistent_message)
    within('#get_started_lightbox') {page.should have_content(message)}
  end

  def expect_persistent_message_in_flash(message = default_persistent_message)
    within('#flash') {page.should have_content(message)}
  end

  def expect_no_persistent_message_in_flash(message = default_persistent_message)
    return unless page.first('#flash')
    within('#flash') {page.should have_no_content(message)}
  end

  context "as a guest user" do
    context "when the demo has a persistent message" do
      before do
        @expected_message = "Goats and groats!"
        @demo.update_attributes(persistent_message: @expected_message)
      end

      context "and there are no flashes" do
        it "shows it" do
          visit activity_path(public_slug: @demo.public_slug)
          page.should have_content(@expected_message)
        end
      end

      it "but not in other pages" do
        visit tiles_path(public_slug: @demo.public_slug)
        page.should have_no_content(@expected_message)
      end
    end

    context "when the demo has no persistent message" do
      it "shows the default if no flashes are present" do
        visit activity_path(public_slug: @demo.public_slug)
        page.should have_content(default_persistent_message)
      end

      it "but not in other pages" do
        visit tiles_path(public_slug: @demo.public_slug)
        page.should have_no_content(default_persistent_message)
      end
    end
  end

  context "when visiting the page as a regular, non-guest user" do
    it "should not show the persistent message" do
      user = FactoryGirl.create(:user)
      user.add_board(@demo)
      user.move_to_new_demo(@demo)

      visit activity_path(as: user)
      should_be_on activity_path
      page.should have_no_css('#flash')
    end
  end

  context "when the get-started lightbox is shown" do
    before do
      # Easiest way to get this to pop is go to a board with active tiles as
      # a guest.
      FactoryGirl.create(:tile, :active, demo: @demo)
    end

    it "should not show the persistent message in the flash", js: true do
      visit activity_path(public_slug: @demo.public_slug)
      page.first('#get_started_lightbox', visible: true).should be_present
      expect_no_persistent_message_in_flash
    end

    it "should show the default persistent message in the get-started lightbox", js: true do
      visit activity_path(public_slug: @demo.public_slug)
      page.first('#get_started_lightbox', visible: true).should be_present
      expect_persistent_message_in_get_started_lightbox
    end

    it "should show the custom persitent message in the get-started lightbox, if used", js: true do
      @demo.update_attributes(persistent_message: "how are you")
      visit activity_path(public_slug: @demo.public_slug)
      page.first('#get_started_lightbox', visible: true).should be_present
      expect_persistent_message_in_get_started_lightbox("how are you")
    end
  end
end
