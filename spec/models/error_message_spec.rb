require 'spec_helper'

describe "Decent error message when something already taken" do
  it "saves two demos with the same name" do
    name = 'Alessandra'
    first = FactoryGirl.create(:demo, name: name)
    begin
      second = FactoryGirl.create(:demo, name: name)
    rescue
    end
  end
end
