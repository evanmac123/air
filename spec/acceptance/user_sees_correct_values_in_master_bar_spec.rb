require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "User Sees Correct Values In Master Bar" do
  def master_bar_progress_selector
    "#{master_bar_selector} .progress"
  end

  def master_bar_selector
    '.mast_bottom .bar'
  end

  def self.user_information
    [
      [{:name => 'Al', :points => 6}, {:points => 6, :points_denominator => 10, :percent => 60.0}],
      [{:name => 'Bob', :points => 16}, {:points => 6, :points_denominator => 10, :percent => 60.0}],
      [{:name => 'Cal', :points => 23}, {:points => 3, :points_denominator => 10, :percent => 30.0}],
      [{:name => 'Dave', :points => 39}, {:points => 9, :points_denominator => 20, :percent => 45.0}],
      [{:name => 'Ed', :points => 62}, {:points => 12, :points_denominator => 30, :percent => 40.0}],
      [{:name => 'Fred', :points => 87}, {:points => 7, :points_denominator => 20, :percent => 35.0}],
      [{:name => 'Ger', :points => 120}, {:points => 20, :points_denominator => 30, :percent => 66.67}],
      [{:name => 'Hal', :points => 10}, {:points => 0, :points_denominator => 10, :percent => 0.0}],
      [{:name => 'Ike', :points => 0}, {:points => 0, :points_denominator => 10, :percent => 0.0}],
      [{:name => 'Jay', :points => 30}, {:points => 0, :points_denominator => 20, :percent => 0.0}],
      [{:name => 'Kay', :points => 100}, {:points => 0, :points_denominator => 30, :percent => 0.0}]
    ]
  end

  before(:each) do
    @demo = FactoryGirl.create :demo, :name => "BarCo", :victory_threshold => 100
    [10, 20, 30, 50, 80, 130].each {|t| FactoryGirl.create :level, :threshold => t, :demo => @demo}
  end

  user_information.each do |user_attributes, expected_values|
    scenario "#{user_attributes[:name]} with #{user_attributes[:points]} points should see #{expected_values[:points]}/#{expected_values[:points_denominator]} points for #{expected_values[:percent]}%" do
      user = FactoryGirl.create :user, user_attributes.merge(:demo => @demo)
      has_password(user, "foobar")
      signin_as(user, "foobar")

      expect_inline_style(master_bar_progress_selector, 'width', "#{expected_values[:percent]}%")

      expected_points_text = "#{expected_values[:points]}/#{expected_values[:points_denominator]} points"

      find(:css, master_bar_selector).text.strip.should == expected_points_text
    end
  end
end
