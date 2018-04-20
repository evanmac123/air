require 'rails_helper'

RSpec.describe Api::ClientAdmin::PopulationSegmentsController, type: :controller do
  render_views

  let(:demo) { FactoryBot.create(:demo) }
  let(:user) { FactoryBot.create(:client_admin, demo: demo) }

  describe "GET #index" do
    it "returns index of population_segments with user_count" do
      3.times { |i| demo.population_segments.create(name: "Segment #{i}") }

      population_segment = demo.population_segments.first
      user.population_segments << population_segment
      user.save

      sign_in_as user

      get :index, { format: :json }
      json = JSON.parse(response.body)
      user_counts = json.map { |segment| segment["user_count"] }

      expect(json.length).to eq(3)
      expect(user_counts).to eq([1, 0, 0])
      expect(response.status).to eq(200)
    end
  end

  describe "POST #create" do
    it "creates a segment" do
      sign_in_as user

      post :create, { population_segment: { name: "Segment" } }

      expect(PopulationSegment.count).to eq(1)
      expect(response).to have_http_status(:success)
    end
  end

  describe "PATCH #update" do
    it "updats a segment" do
      segment = demo.population_segments.create(name: "Segment")

      sign_in_as user

      get :update, { id: segment.id, population_segment: { name: "New Name" } }

      expect(PopulationSegment.first.name).to eq("New Name")
      expect(response).to have_http_status(:success)
    end
  end

  describe "DELETE #destroy" do
    it "deletes the segment" do
      segment = demo.population_segments.create(name: "Segment")

      sign_in_as user

      delete :destroy, { id: segment.id }


      expect(response.status).to eq(204)
      expect(PopulationSegment.count).to eq(0)
    end
  end

end
