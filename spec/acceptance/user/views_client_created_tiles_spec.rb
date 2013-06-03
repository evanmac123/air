require 'acceptance/acceptance_helper'

feature 'User views client created tiles' do
  def expect_supporting_content(expected_content)
    expect_content expected_content
  end

  def expect_question(question)
    expect_content question
  end

  def expect_points(points)
    expect_content "#{points} points"
  end

  scenario 'and all the extra cool stuff around them' do
    tile = FactoryGirl.create(:tile, :client_created, supporting_content: "Vote Quimby", question: "Who should you vote for?", link_address: 'foo')
    tile.first_rule.update_attributes(points: 20)
    user = FactoryGirl.create(:user, demo: tile.demo)
    visit tiles_path(as: user)

    expect_supporting_content "Vote Quimby"
    expect_question "Who should you vote for?"
    expect_points 20
  end
end
