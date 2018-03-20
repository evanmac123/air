require 'acceptance/acceptance_helper'

feature "Client admin previews invite email", js: true do
  let! (:client_admin) { FactoryBot.create(:client_admin) }

  context "without tiles in demo" do
    context "digest email" do
      before do
        visit email_client_admin_tiles_digest_preview_path(as: client_admin)
      end

      it "should show empty digest email" do
        expect_content "Your New Tiles Are Here!"
        expect_content "No tiles posted"
      end
    end

    context "follow up email" do
      before do
        visit email_client_admin_tiles_digest_preview_path(follow_up_email: true, as: client_admin)
      end

      it "should show empty follow up email" do
        expect_content "Don't miss your new tiles"
        expect_content "No tiles posted"
      end
    end
  end
end
