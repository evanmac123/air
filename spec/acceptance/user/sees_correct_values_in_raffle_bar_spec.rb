require 'acceptance/acceptance_helper'

feature "User sees correct values in rafle bar" do

  def self.user_information
    [
      [{:name => 'Al', :points => 6, tickets: 0}, {:points => 6, tickets: 0, :percent => 30}],
      [{:name => 'Bob', :points => 16, tickets: 0}, {:points => 16, tickets: 0, :percent => 80}],
      [{:name => 'Cal', :points => 23, tickets: 1}, {:points => 3, tickets: 1, :percent => 15}],
      [{:name => 'Dave', :points => 39, tickets: 1}, {:points => 19, tickets: 1, :percent => 95}],
      [{:name => 'Ed', :points => 62, tickets: 3}, {:points => 2, tickets: 3, :percent => 10}],
      [{:name => 'Hal', :points => 10, tickets: 0}, {:points => 10, tickets: 0, :percent => 50}],
      [{:name => 'Ike', :points => 0, tickets: 0}, {:points => 0, tickets: 0, :percent => 0}],
      [{:name => 'Jay', :points => 30, tickets: 1}, {:points => 10, tickets: 1, :percent => 50}]
    ]
  end

  before(:each) do
    @demo = FactoryGirl.create(:demo, :with_tickets)
    raffle = @demo.raffle = FactoryGirl.create(:raffle, :live, demo: @demo)
  end

  user_information.each do |user_attributes, expected_values|
    scenario "#{user_attributes[:name]} with #{user_attributes[:points]} points should see #{expected_values[:points]}/#{expected_values[:points_denominator]} points for #{expected_values[:percent]}%" do
      user = FactoryGirl.create :user, user_attributes
      user.demo = @demo
      user.save
      
      user.demo.uses_tickets.should be_true

      has_password(user, "foobar")
      signin_as(user, "foobar")

      expect_raffle_progress expected_values[:percent]
      expect_raffle_entries expected_values[:tickets]
    end
  end
end
