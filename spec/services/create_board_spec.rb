require 'spec_helper'

describe CreateBoard do
  describe "#create" do
    context "board email" do
      it "should create board with unique email based on public slug" do
        b = FactoryBot.create :demo, 
                                name: "scooby doo Board", 
                                public_slug: "scooby-doo", 
                                email: "scoobydoo@ourairbo.com"

        creator = CreateBoard.new("scooby-doo")
        creator.create
        b2 = creator.board
        expect(b2.name).to eq("scooby-doo Board")
        expect(b2.public_slug).to eq("scoobydoo")
        expect(b2.email).to eq("scoobydoo2@ourairbo.com")
      end
    end
  end
end