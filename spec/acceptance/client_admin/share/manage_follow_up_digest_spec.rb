require 'acceptance/acceptance_helper'


feature "Client admin modifies the follow digest email", js: true do

  before do
    @demo = FactoryGirl.create(:demo)
    @admin = FactoryGirl.create :client_admin, email: 'client-admin@hengage.com', demo: @demo

    @user1 = FactoryGirl.create(:user, accepted_invitation_at: 1.month.ago, demo: @demo)
    @user2 = FactoryGirl.create(:user, accepted_invitation_at: 1.month.ago, demo: @demo)
    @user3 = FactoryGirl.create(:user, accepted_invitation_at: 1.month.ago, demo: @demo)

    @tiles = FactoryGirl.create_list(:tile, 2, :active, demo: @demo, )

    digest = TilesDigest.create(
      demo: @demo,
      tile_ids: @tiles.map(&:id),
      subject: "orig subject",
      headline: "headline",
      include_unclaimed_users: true,
      sender: @admin,
      sent_at: Time.current + 1.day
    )

    @fu = digest.create_follow_up_digest_email(
      send_on: Time.current + 1.month
    )

    @rowSelector = ".followups #fu_#{@fu.id}"

    visit client_admin_share_path(as: @admin)

    find('.js-share-follow-ups-component-tab').click
  end

  context "Editing subject" do
    scenario "confirms subject change"  do

      within(".share-follow-ups-component") do
        click_link "Edit"
      end

      within modal_form do
        fill_in "Subject", with: "New Subject"
        click_link "Save"
      end

      expect(page).to have_content(ClientAdmin::TilesFollowUpEmailController::SAVE_SUCCESS)

      within @rowSelector do
        expect(page).to have_content 'New Subject'
      end
    end

    scenario "reverts to default subject" do
      within @rowSelector do
        click_link "Edit"
      end

      within modal_form do
        fill_in "Subject", with: "New Subject"
        click_link "Save"
      end

      expect(page).to have_content(ClientAdmin::TilesFollowUpEmailController::SAVE_SUCCESS)

      within @rowSelector do
        expect(page).to have_content 'New Subject'
      end

      within @rowSelector do
        click_link "Edit"
      end

      within modal_form do
        fill_in "Subject", with: ""
        click_link "Save"
      end

      within @rowSelector do
        expect(page).to have_content "Don't Miss: orig subject"
      end
    end
  end

  context "send now"  do
    before do
      within @rowSelector do
        click_link "Send Now"
      end
    end

    scenario "confirm" do
      within sweet_alert_popup do
        click_button "OK"
      end

      expect(page).to have_content(ClientAdmin::TilesFollowUpEmailController::SEND_NOW_SUCCESS)
      expect(page).to have_no_css(@rowSelector)

      expect(ActionMailer::Base.deliveries.count).to eq(4)

      subjects_sent = ActionMailer::Base.deliveries.map(&:subject).uniq

      expect(subjects_sent).to eq(["Don't Miss: orig subject"])
    end

    scenario "cancel" do
      within sweet_alert_popup do
        click_button "Cancel"
      end
      expect(page).to have_css(@rowSelector)
    end
  end

  context "delete"  do
    before do
      within @rowSelector do
        click_link "Cancel"
      end
    end

    scenario "confirm" do
      within sweet_alert_popup do
        click_button "OK"
      end

      expect(page).to have_content(ClientAdmin::TilesFollowUpEmailController::DELETE_SUCCESS)
      expect(page).to have_no_css(@rowSelector)
    end

    scenario "cancel" do
      within sweet_alert_popup do
        click_button "Cancel"
      end

      expect(page).to have_css(@rowSelector)
    end
  end

  def sweet_alert_popup
    ".sweet-alert.airbo.showSweetAlert.visible"
  end

  def modal_form
    ".follow-up-email-form"
  end
end
