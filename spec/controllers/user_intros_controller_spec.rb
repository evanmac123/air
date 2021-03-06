require 'spec_helper'
describe UserIntrosController do
 before do
  end
  describe "PUT #update" do
    it "sends 200 status when user is logged in" do
      @demo = FactoryBot.create(:demo)
      @kendra = FactoryBot.create(:user, demo: @demo, password: 'milking', session_count: 5)
      FactoryBot.create(:tile, headline: "I'm a tile", demo: @demo, activated_at: 1.day.ago)
      sign_in_as(@kendra)
      xhr :put, :update, {intro: "displayed_first_tile_hint"}
      expect(response.code).to eq("200")
    end

    it "completes with 200 status code as a guest_user" do
      @demo = FactoryBot.create(:demo)
      FactoryBot.create(:tile, demo: @demo)
      session[:guest_user]={demo_id: @demo.id}
      xhr :put, :update, {intro: "displayed_first_tile_hint"}
      expect(response.code).to eq("200")
    end
  end
end
