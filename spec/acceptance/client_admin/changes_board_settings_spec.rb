require 'acceptance/acceptance_helper'

feature "Client Admin Changes Board Settings" do
  context "board name form" do
    let(:admin) {FactoryGirl.create(:client_admin, voteup_intro_seen: true, share_link_intro_seen: true)}
  end
end