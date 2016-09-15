require 'acceptance/acceptance_helper'


feature "Potential client recieves an invitation to try airbo and clicks link in email", js: true do
  before do
    FactoryGirl.create_list(:topic_board, 3, :valid, is_reference: true)
  end

  context 'As the first potential client in an organization' do
    context "when I click the onboarding link in the email I received from airbo" do
      it "takes me through the entire onboarding flow" do
        visit onboarding_email_link
        expect(page).to have_css(".topic-board", count: TopicBoard.reference_board_set.count)

        topic_board = TopicBoard.reference_board_set.first

        within ".topic-boards" do
          page.find(".topic-board", text: topic_board.topic_name).click
        end

        expect(current_path).to eq("/myairbo/#{UserOnboarding.first.id}")

        within "#tile_wall" do
          expect(page).to have_css(".tile_container", count: topic_board.tiles.count)
        end
      end
    end
  end

  def onboarding_email_link
    "/newairbo?email=test%40test.com&name=Test+Name&onboard=true&organization=Test+Company"
  end
end
