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
        include_unclaimed_users: false,
        sender: @admin
      )

      @fu = digest.create_follow_up_digest_email(
        send_on: Date.new(2016-8-22),
        user_ids_to_deliver_to: User.all.map(&:id),
        subject: "Dont Miss: orig subject",
      )

      @rowSelector = ".followups #fu_#{@fu.id}"
  end

  context "Editing subject" do
    context "when no alt subject" do
      scenario "confirms subject change"  do
        visit client_admin_share_path(as: @admin)

        within @rowSelector do
          click_link "Edit"
        end

        within modal_form do
          expect(page).to_not have_content("Alternate Subject")

          fill_in "Subject", with: "New Subject"
          click_link "Save"
        end

        expect(page).to have_content(ClientAdmin::TilesFollowUpEmailController::SAVE_SUCCESS)

        within @rowSelector do
          expect(page).to have_content 'New Subject'
        end
      end
    end

    context "when alt subject" do
      scenario "confirms both subject changes"  do
        @fu.update_attributes(alt_subject: "ALT SUBJECT")
        @fu.reload

        visit client_admin_share_path(as: @admin)

        within @rowSelector do
          click_link "Edit"
        end

        within modal_form do
          expect(page).to have_content("Alternate Subject")

          fill_in "Subject", with: "New Subject"
          fill_in "Alternate Subject", with: "New Alt Subject"
          click_link "Save"
        end

        visit client_admin_share_path(as: @admin)

        within @rowSelector do
          click_link "Edit"
        end

        within modal_form do
          expect(page).to  have_xpath("//input[@value='New Subject']")
          expect(page).to  have_xpath("//input[@value='New Alt Subject']")
        end
      end
    end
  end

  context "send now"  do
    context "when no alt subject" do
      before do
        visit client_admin_share_path(as: @admin)

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

    context "when alt subject" do
      before do
        @fu.update_attributes(alt_subject: "ALT SUBJECT")
        @fu.reload

        visit client_admin_share_path(as: @admin)

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

        expect(subjects_sent.sort).to eq(["ALT SUBJECT", "Don't Miss: orig subject"])
      end
    end
  end

  context "delete"  do
    before do
      visit client_admin_share_path(as: @admin)

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
    "#manage_follow_up.reveal-modal"
  end
end
