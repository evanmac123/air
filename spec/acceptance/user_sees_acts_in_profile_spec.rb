require 'acceptance/acceptance_helper'

feature 'User sees acts in profile' do
  def make_acts
    %w(a b c d e f g h i j k).each {|letter| FactoryGirl.create(:act, user: @user, text: "did #{letter}")}
  end

  before do
    @user = FactoryGirl.create(:user)
    @other_user_in_same_demo = FactoryGirl.create(:user, demo: @user.demo)
    has_password @other_user_in_same_demo, 'foobar'
    signin_as @other_user_in_same_demo, 'foobar'
  end

  context 'when the acting user has their privacy level set to everybody' do
    before do
      @user.update_attributes(privacy_level: 'everybody')
      make_acts
    end

    scenario 'anyone in that demo should be able to see their acts', js: true do
      visit user_path(@user)
      expect_content "did k"
      expect_no_content "did a"

      click_link "See more"
      expect_content "did k"
      expect_content "did a"
    end
  end

  context "when the acting user has their privacy level set to connected" do
    before do
      @user.update_attributes(privacy_level: 'connected')
      make_acts
    end

    context 'and the viewing user is not a friend of the acting user' do
      scenario "should result in them seeing no acts", js: true do
        visit user_path(@user)
        expect_no_content "did k"
        expect_no_content "did a"

        click_link "See more"
        expect_no_content "did k"
        expect_no_content "did a"
      end

      context "but they are a site admin" do
        before do
          @other_user_in_same_demo.is_site_admin = true
          @other_user_in_same_demo.save!
        end

        scenario "should be able to see the acts", js: true do
          visit user_path(@user)
          expect_content "did k"
          expect_no_content "did a"

          click_link "See more"
          expect_content "did k"
          expect_content "did a"
        end
      end
    end

    context 'and the viewing user is a friend of the acting user' do
      before do
        FactoryGirl.create(:friendship, user: @other_user_in_same_demo, friend: @user, state: Friendship::State::ACCEPTED)
      end

      scenario "should be able to see that user's acts", js: true do
        visit user_path(@user)
        expect_content "did k"
        expect_no_content "did a"

        click_link "See more"
        expect_content "did k"
        expect_content "did a"
      end
    end
  end
end
