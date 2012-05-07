require 'spec_helper'

describe Report::Activity do
  describe "report_csv" do
    it "should return the expected data, cleaned of user's names" do
      @demo = FactoryGirl.create :demo
      [10,25,45].each {|threshold| FactoryGirl.create :level, :demo => @demo, :threshold => threshold}

      @location = FactoryGirl.create :location, :name => "Somerville"
      @user1 = FactoryGirl.create :user, :demo => @demo
      @user2 = FactoryGirl.create :user, :demo => @demo, :location => @location
      @user3 = FactoryGirl.create :user, :demo => @demo

      FactoryGirl.create :act, :demo => @demo, :user => @user1, :text => "made toast", :inherent_points => 7, :created_at => Chronic.parse("5/1/2010 12:43PM")
      FactoryGirl.create :act, :demo => @demo, :user => @user1, :text => "got credit for referring June Cleaver to the game", :inherent_points => 5, :created_at => Chronic.parse("5/1/2010 12:44PM")
      FactoryGirl.create :act, :demo => @demo, :user => @user1, :text => "credited Lucy Furr for referring them to the game", :inherent_points => 7, :created_at => Chronic.parse("5/2/2010 2:23PM")
      FactoryGirl.create :act, :demo => @demo, :user => @user1, :text => "is now friends with Major League Football", :inherent_points => 3, :created_at => Chronic.parse("5/3/2010 9:17PM")
      FactoryGirl.create :act, :demo => @demo, :user => @user1, :text => "told James Baldwin about a command", :inherent_points => 0, :created_at => Chronic.parse("5/3/2010 9:23PM")
      FactoryGirl.create :act, :demo => @demo, :user => @user1, :text => "ate a kitten of course (thanks The Tick for the referral)", :inherent_points => 2, :referring_user => @user2, :created_at => Chronic.parse("5/4/2010 5:23PM")
      FactoryGirl.create :act, :demo => @demo, :user => @user2, :text => "went nuts", :created_at => Chronic.parse("5/5/2010 12:00PM")

      csv_output = Report::CleanedActivity.new(@demo.id).report_csv
      csv_output.should == <<-END_EXPECTED_CSV
Date,Hour,Minute,User ID,Text,Points,Referring user ID,User points,User level,Location
2010-05-01,12,43,#{@user1.id},made toast,7,,#{@user1.points},#{@user1.top_level_index},#{@user1.location.try(:name)}
2010-05-01,12,44,#{@user1.id},got credit for referring someone to the game,5,,#{@user1.points},#{@user1.top_level_index},#{@user1.location.try(:name)}
2010-05-02,14,23,#{@user1.id},credited someone for referring them to the game,7,,#{@user1.points},#{@user1.top_level_index},#{@user1.location.try(:name)}
2010-05-03,21,17,#{@user1.id},is now friends with someone,3,,#{@user1.points},#{@user1.top_level_index},#{@user1.location.try(:name)}
2010-05-03,21,23,#{@user1.id},told someone about a command,0,,#{@user1.points},#{@user1.top_level_index},#{@user1.location.try(:name)}
2010-05-04,17,23,#{@user1.id},ate a kitten of course,2,#{@user2.id},#{@user1.points},#{@user1.top_level_index},#{@user1.location.try(:name)}
2010-05-05,12,00,#{@user2.id},went nuts,,,#{@user2.points},#{@user2.top_level_index},#{@user2.location.try(:name)}
      END_EXPECTED_CSV
    end
  end
end
