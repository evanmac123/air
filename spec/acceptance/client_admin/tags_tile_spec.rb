require 'acceptance/acceptance_helper'

feature 'Tags tile' do
  it "creating a tile with an existing tag"
  it "creating a tile with a new tag"
  it "editing a tile with an existing tag"
  it "editing a tile with a new tag"
  it "normalizes tag names so they look consistent"
  it "does not let a duplicate tag be created"
end
