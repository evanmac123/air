require 'acceptance/acceptance_helper'

feature "User sees correct values in master bar" do
 def master_bar_progress_selector
    ".progress"
  end

  def master_bar_selector
    '.progress_bar_points'
  end

  def self.user_information
    [
      [{:name => 'Al', :points => 6}, {:points => 6, :percent => 30.0}],
      [{:name => 'Bob', :points => 16}, {:points => 16, :percent => 80.0}],
      [{:name => 'Cal', :points => 23}, {:points => 3, :percent => 15.0}],
      [{:name => 'Dave', :points => 39}, {:points => 19, :percent => 95.0}],
      [{:name => 'Ed', :points => 62}, {:points => 2, :percent => 10.0}],
      [{:name => 'Hal', :points => 10}, {:points => 10, :percent => 50.0}],
      [{:name => 'Ike', :points => 0}, {:points => 0, :percent => 0.0}],
      [{:name => 'Jay', :points => 30}, {:points => 10, :percent => 50.0}]
    ]
  end

  user_information.each do |user_attributes, expected_values|
    scenario "#{user_attributes[:name]} with #{user_attributes[:points]} points should see #{expected_values[:points]}/#{expected_values[:points_denominator]} points for #{expected_values[:percent]}%" do
      user = FactoryGirl.create :user, user_attributes
      user.demo.uses_tickets.should be_true

      has_password(user, "foobar")
      signin_as(user, "foobar")

      expect_inline_style(master_bar_progress_selector, 'width', "#{expected_values[:percent]}%")

      expected_points_text = "#{expected_values[:points]}/20 points"

      find(:css, master_bar_selector).text.strip.should == expected_points_text
    end
  end
end
