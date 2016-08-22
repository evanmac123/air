require 'acceptance/acceptance_helper'

#Capybara.javascript_driver=:selenium

feature "Client admin modifies the follow digest email", js: true do

  before do
      @demo = FactoryGirl.create(:demo)
      @admin = FactoryGirl.create :client_admin, email: 'client-admin@hengage.com', demo: @demo

      @user1 = FactoryGirl.create(:user, accepted_invitation_at: 1.month.ago, demo: @demo)
      @user2 = FactoryGirl.create(:user, accepted_invitation_at: 1.month.ago, demo: @demo)
      @user3 = FactoryGirl.create(:user, accepted_invitation_at: 1.month.ago, demo: @demo)

      @tiles = FactoryGirl.create_list(:tile, 2, :active, demo: @demo, )
      
      @fu = FollowUpDigestEmail.create(original_digest_headline: "headline",
                                       original_digest_subject: "orig subject",
                                       demo_id: @demo.id,
                                       send_on: Date.new(2016-8-22), unclaimed_users_also_get_digest: false, 
                                       user_ids_to_deliver_to: User.all.map(&:id), 
                                       tile_ids: @tiles.map(&:id)
                                   )


      @rowSelector = ".followups-list #fu_#{@fu.id}"
    #bypass_modal_overlays(admin)
    visit client_admin_share_path(as: @admin)
  end

  context "Editing send on and subject" do
    scenario "confirms change"  do
      within @rowSelector do
        click_link "Edit"
        fill_in "original_digest_subject", with: "New Subject"
        fill_in "send_on", with: "2000-12-31"
        click_link "Save"
      end

      expect(page).to have_content(ClientAdmin::TilesFollowUpEmailController::SAVE_SUCCESS)

        within @rowSelector do
          expect(page).to have_field 'original_digest_subject', disabled: true, with: 'New Subject'
          expect(page).to have_field 'send_on', disabled: true, with: '2000-12-31'
        end
      #TODO figure out if i like this pattern
    end

    scenario "cancels changes"  do
      within @rowSelector do
        click_link "Edit"
        fill_in "original_digest_subject", with: "New Subject"
        fill_in "send_on", with: "2000-12-31"
        click_link "Cancel"
        expect(page).to have_field 'original_digest_subject', disabled: true, with: @fu.original_digest_subject
        expect(page).to have_field 'send_on', disabled: true, with: @fu.send_on
      end
    end

  end

  context "send now"  do
    scenario "confirm" do
      within @rowSelector do
        click_link "Send Now"
      end
      within sweet_alert_popup do
        click_button "OK"
      end

      expect(page).to have_content(ClientAdmin::TilesFollowUpEmailController::SEND_NOW_SUCCESS)
      expect(page).to have_css(".no-follow-up", visible: true)
      expect(page).to have_no_css(@rowSelector)
    end

    scenario "cancel" do
      within @rowSelector do
        click_link "Send Now"
      end

      within sweet_alert_popup do
        click_button "Cancel"
      end
      expect(page).to have_css(".no-follow-up", visible: false)
      expect(page).to have_css(@rowSelector)
    end

  end

  context "delete"  do
    scenario "confirm" do
      within @rowSelector do
        click_link "Delete"
      end

      within sweet_alert_popup do
        click_button "OK"
      end

      expect(page).to have_content(ClientAdmin::TilesFollowUpEmailController::DELETE_SUCCESS)
      expect(page).to have_css(".no-follow-up", visible: true)
      expect(page).to have_no_css(@rowSelector)
    end

    scenario "cancel" do
      within @rowSelector do
        click_link "Delete"
      end

      within sweet_alert_popup do
        click_button "Cancel"
      end

      expect(page).to have_css(".no-follow-up", visible: false)
      expect(page).to have_css(@rowSelector)
    end

  end

  def sweet_alert_popup
    ".sweet-alert.airbo.showSweetAlert.visible"
  end

end
