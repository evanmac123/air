require 'acceptance/acceptance_helper'

feature 'guest user who tries to play outside of the sandbox' do
  let (:board) { FactoryGirl.create :demo, :with_public_slug }

  before do
    visit public_board_path(public_slug: board.public_slug)
  end

  def expect_sandbox_reprimand
    expect_content "Save your progress to access this part of the site."
  end

  paths_to_test = [
    # Can't remember the incantation to get at the handy path helpers, nor can I find it right now
    "/users/guestuser",
    "/users/otherguy",
    "/users",
    "/account/settings/edit",
    "/admin",
    "/client_admin"
  ]

  context "going to certain paths" do
    paths_to_test.each do |path_to_test|
      context "going to #{path_to_test}" do
        it "should get redirected to the activity path with a helpful message" do
          visit path_to_test
          should_be_on public_activity_path(board.public_slug)
        end
      end

      pending "should have a live save-progress link", js: true do
        #This test should be deprected 
        visit path_to_test
        click_link "Save your progress"
        expect_conversion_form
      end
    end
  end
end
