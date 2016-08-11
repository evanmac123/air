require 'spec_helper'
describe UserIntrosController do
 before do
    @demo = FactoryGirl.create(:demo)
    @kendra = FactoryGirl.create(:user, demo: @demo, password: 'milking', session_count: 5)
    FactoryGirl.create(:tile, headline: "I'm a tile", demo: @demo, activated_at: 1.day.ago)
  end
  describe "PUT #update" do
    it "completes with 200 status code" do
      sign_in_as(@kendra)
      xhr :put, :update, {intro: "displayed_first_tile_hint"}
      response.code.should == "200"
    end

  end
end
