require 'acceptance/acceptance_helper'

feature 'Sees persistent message when appropriate in activity page' do
  def default_persistent_message
    "Airbo is an interactive communication tool. Read information and answer questions on the tiles to earn points."  
  end

  before do
    @demo = FactoryGirl.create(:demo, is_public: true)
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
end
