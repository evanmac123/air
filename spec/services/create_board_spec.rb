require 'spec_helper'

describe CreateBoard do
  describe "#create" do
    context "board email" do
      it "should create board with unique email based on public slug" do
        b = FactoryGirl.create :demo, 
                                name: "scooby doo Board", 
                                public_slug: "scooby-doo", 
                                email: "scoobydoo@ourairbo.com"

        creator = CreateBoard.new("scooby-doo")
        creator.create
        b2 = creator.board
        b2.name.should == "scooby-doo Board"
        b2.public_slug.should == "scoobydoo"
        b2.email.should == "scoobydoo2@ourairbo.com"
      end
    end
  end
end