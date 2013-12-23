require 'acceptance/acceptance_helper'

feature 'guest user who tries to play outside of the sandbox' do
  let (:board) { FactoryGirl.create :demo, :with_public_slug }

  before do
    visit public_board_path(public_slug: board.public_slug)
  end

  def expect_sandbox_reprimand
    expect_content "That function is restricted to signed-in users. If you already have an account with H.Engage, click here to sign in."
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
          should_be_on activity_path
          expect_sandbox_reprimand

          click_link "click here to sign in"
          should_be_on new_session_path
        end
      end
    end
  end
end
