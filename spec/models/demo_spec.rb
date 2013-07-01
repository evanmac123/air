require 'spec_helper'

describe Demo do
  it { should have_many(:users) }
  it { should have_many(:rules) }
  it { should have_many(:rule_values).through(:rules) }
  it { should have_many(:surveys) }
  it { should have_many(:survey_questions).through(:surveys) }
  it { should have_many(:goals) }
  it { should have_many(:tiles) }
  it { should have_many(:locations) }
  it { should have_many(:characteristics) }
  it { should have_one(:skin) }
end

describe Demo, "when both begins_at and ends_at are set" do
  it "should validate that ends_at is later than begins_at" do
    FactoryGirl.build(:demo, :begins_at => Time.now + 2.hours, :ends_at => Time.now).should_not be_valid
  end
end

describe Demo, "#welcome_message" do
  before(:each) do
    @demo = FactoryGirl.create :demo
    @user = FactoryGirl.create :user, :demo => @demo
  end

  context "when the demo has no custom welcome message" do
    before(:each) do
      @demo.custom_welcome_message.should be_nil
    end

    it "should return a reasonable default" do
      @demo.welcome_message(@user).should == "You've joined the #{@demo.name} game! @{reply here}"
    end
  end

  context "when the demo has a custom welcome message" do
    before(:each) do
      @demo.custom_welcome_message = "Derp derp! Let's play! You are %{unique_id}, we are %{name}!"
    end

    it "should use that" do
      @demo.welcome_message(@user).should == "Derp derp! Let's play! You are #{@user.sms_slug}, we are #{@demo.name}!"
    end
  end
end

describe Demo, "#game_over?" do
  before(:each) do
    @demo = FactoryGirl.create :demo
  end

  context "for a demo with no ending time set" do
    before(:each) do
      @demo.ends_at.should be_nil
    end

    it "should return false" do
      @demo.game_over?.should be_false
    end
  end

  context "for a demo with an ending time set" do
    before(:each) do
      @demo.ends_at = Time.parse("2010-05-01 12:00:00 UTC")
    end

    after(:each) do
      Timecop.return
    end

    context "at or before the ending time" do
      before(:each) do
        Timecop.freeze(Time.parse("2010-05-01 12:00:00 UTC"))
      end

      it "should return false" do
        @demo.game_over?.should be_false
      end
    end

    context "after that ending time" do
      before(:each) do
        Timecop.freeze(Time.parse("2010-05-01 12:00:01 UTC"))
      end

      it "should return true" do
        @demo.game_over?.should be_true
      end
    end
  end
end

describe Demo, ".alphabetical" do
  before do
    Demo.delete_all
    @red_sox  = FactoryGirl.create(:demo, :name => "Red Sox")
    @gillette = FactoryGirl.create(:demo, :name => "Gillette")
  end

  it "finds all demos, sorted alphabetically" do
    Demo.alphabetical.should == [@gillette, @red_sox]
  end
end

describe Demo, "#print_pending_friendships" do
  it "tells us how many friendships have been initiated and accepted" do 
    demo = FactoryGirl.create(:demo)
    user1 = FactoryGirl.create(:user, :demo => demo)
    user2 = FactoryGirl.create(:user, :demo => demo)
    user3 = FactoryGirl.create(:user, :demo => demo)
    user4 = FactoryGirl.create(:user, :demo => demo)
    user1.befriend user2
    user1.befriend user3
    user1.befriend user4
    user4.accept_friendship_from user1
    expected = "#{demo.name} has 3 initiated friendships, 1 of which have been accepted (33.333333333333336%)"
    demo.print_pending_friendships.should == expected


  end
end

describe Demo, "#tutorial_success" do
  before do
   @demo = FactoryGirl.create :demo
   @user1 = FactoryGirl.create :user, :demo_id => @demo.id
   @user2 = FactoryGirl.create :user, :demo_id => @demo.id
   @user3 = FactoryGirl.create :user, :demo_id => @demo.id
   tutorial1 = Tutorial.create(:user_id => @user1.id)
   tutorial2 = Tutorial.create(:user_id => @user2.id) 
  end
  
  it "finds out if we met our goals" do
    @demo.tutorial_success
    demo2 = FactoryGirl.create :demo
    demo2.tutorial_success
  end
end

describe Demo, "ticket fields" do
  context "when uses_tickets is set" do
    before(:each) do
      @demo = FactoryGirl.build_stubbed(:demo)
      @demo.uses_tickets.should be_true
      @demo.ticket_threshold = nil
    end

    it "should validate that ticket_threshold is set" do
      @demo.should_not be_valid
      @demo.errors.keys.should include(:ticket_threshold)

      @demo.ticket_threshold = 5
      @demo.should be_valid
    end
  end
end

describe Demo, "phone number" do
  it "should normalize itself on save" do
    @demo = FactoryGirl.build(:demo)
    @demo.phone_number = "(617) 555-1212"
    @demo.save
    @demo.reload.phone_number.should == "+16175551212"
  end
end

describe Demo, "when internal email domains are changed" do
  it "should re-segment everybody" do
    demo = FactoryGirl.create(:demo)
    demo.internal_domains.should be_empty

    user1 = FactoryGirl.create(:user, demo: demo, email: "user@foo.com")
    user2 = FactoryGirl.create(:user, demo: demo, email: "user@bar.com")
    user3 = FactoryGirl.create(:user, demo: demo, email: "user@baz.com")
    crank_dj_clear

    [user1, user2, user3].all?{|u| u.segmentation_data.email_has_internal_domain == false}.should be_true

    demo.internal_domains = %w(bar.com)
    demo.save!
    crank_dj_clear

    [user1, user3].all?{|u| u.segmentation_data.reload.email_has_internal_domain == false}.should be_true
    [user2].all?{|u| u.segmentation_data.reload.email_has_internal_domain == true}.should be_true

    demo.internal_domains = %w(baz.com foo.com)
    demo.save!
    crank_dj_clear

    [user2].all?{|u| u.segmentation_data.reload.email_has_internal_domain == false}.should be_true
    [user1, user3].all?{|u| u.segmentation_data.reload.email_has_internal_domain == true}.should be_true
  end
end

# Don't actually need everything to have a variable name, but adds to readability and might come in handy for future tests
describe Demo, '#send_digest_email' do
  it 'returns only those demos which should send out a digest email on the current day' do

    monday_demo_1_with_tiles = FactoryGirl.create :demo, tile_digest_email_send_on: 'Monday', tile_digest_email_sent_at: 1.week.ago
    monday_demo_2_with_tiles = FactoryGirl.create :demo, tile_digest_email_send_on: 'Monday', tile_digest_email_sent_at: 1.week.ago
    monday_demo_3_with_tiles = FactoryGirl.create :demo, tile_digest_email_send_on: 'Monday', tile_digest_email_sent_at: 1.week.ago

    monday_demo_with_no_tiles_to_send = FactoryGirl.create :demo, tile_digest_email_send_on: 'Monday', tile_digest_email_sent_at: 1.week.ago

    # -------------------------------------

    tuesday_demo_with_no_tiles_at_all  = FactoryGirl.create :demo, tile_digest_email_send_on: 'Tuesday', tile_digest_email_sent_at: 1.week.ago
    # Not even any demos for Wednesday
    thursday_demo_with_no_tiles_at_all = FactoryGirl.create :demo, tile_digest_email_send_on: 'Thursday', tile_digest_email_sent_at: 1.week.ago

    # -------------------------------------

    friday_demo_1_with_tiles = FactoryGirl.create :demo, tile_digest_email_send_on: 'Friday', tile_digest_email_sent_at: 1.week.ago
    friday_demo_2_with_tiles = FactoryGirl.create :demo, tile_digest_email_send_on: 'Friday', tile_digest_email_sent_at: 1.week.ago
    friday_demo_3_with_tiles = FactoryGirl.create :demo, tile_digest_email_send_on: 'Friday', tile_digest_email_sent_at: 1.week.ago

    friday_demo_with_no_tiles_to_send = FactoryGirl.create :demo, tile_digest_email_send_on: 'Friday', tile_digest_email_sent_at: 1.week.ago

    # -------------------------------------

    Timecop.travel Date.today.beginning_of_week(:sunday)  # All newly-created tiles will qualify for the digest email

    # -------------------------------------

    # Tiles that should go out (created after the 'last-sent-date' and not 'archived')
    monday_demo_1_tile_1 = FactoryGirl.create :tile, demo: monday_demo_1_with_tiles, headline: 'monday_demo_1_tile_1'

    monday_demo_2_tile_1 = FactoryGirl.create :tile, demo: monday_demo_2_with_tiles, headline: 'monday_demo_2_tile_1'
    monday_demo_2_tile_2 = FactoryGirl.create :tile, demo: monday_demo_2_with_tiles, headline: 'monday_demo_2_tile_2'

    monday_demo_3_tile_1 = FactoryGirl.create :tile, demo: monday_demo_3_with_tiles, headline: 'monday_demo_3_tile_1'
    monday_demo_3_tile_2 = FactoryGirl.create :tile, demo: monday_demo_3_with_tiles, headline: 'monday_demo_3_tile_2'
    monday_demo_3_tile_3 = FactoryGirl.create :tile, demo: monday_demo_3_with_tiles, headline: 'monday_demo_3_tile_3'

    # -------------------------------------

    friday_demo_1_tile_1 = FactoryGirl.create :tile, demo: friday_demo_1_with_tiles, headline: 'friday_demo_1_tile_1'

    friday_demo_2_tile_1 = FactoryGirl.create :tile, demo: friday_demo_2_with_tiles, headline: 'friday_demo_2_tile_1'
    friday_demo_2_tile_2 = FactoryGirl.create :tile, demo: friday_demo_2_with_tiles, headline: 'friday_demo_2_tile_2'

    friday_demo_3_tile_1 = FactoryGirl.create :tile, demo: friday_demo_3_with_tiles, headline: 'friday_demo_3_tile_1'
    friday_demo_3_tile_2 = FactoryGirl.create :tile, demo: friday_demo_3_with_tiles, headline: 'friday_demo_3_tile_2'
    friday_demo_3_tile_3 = FactoryGirl.create :tile, demo: friday_demo_3_with_tiles, headline: 'friday_demo_3_tile_3'

    # -------------------------------------

    # Tiles that should not go out

    # Tiles that were created before the 'last-sent-at' date ( => supposedly went out in that batch)
    monday_no_tile_1 = FactoryGirl.create :tile, demo: monday_demo_with_no_tiles_to_send, headline: 'monday_no_tile_1', created_at: 2.weeks.ago
    monday_no_tile_2 = FactoryGirl.create :tile, demo: monday_demo_with_no_tiles_to_send, headline: 'monday_no_tile_2', created_at: 2.weeks.ago

    # Tiles that have been 'archived'
    friday_no_tile_1 = FactoryGirl.create :tile, demo: friday_demo_with_no_tiles_to_send, headline: 'friday_no_tile_1', status: Tile::ARCHIVE
    friday_no_tile_2 = FactoryGirl.create :tile, demo: friday_demo_with_no_tiles_to_send, headline: 'friday_no_tile_2', status: Tile::ARCHIVE

    # -------------------------------------

    Timecop.travel Date.today.beginning_of_week(:monday)
    demos = Demo.send_digest_email

    demos.should have(3).demos

    [monday_demo_1_with_tiles, monday_demo_2_with_tiles, monday_demo_3_with_tiles].each_with_index do |demo, i|
      demos.should include(demo)
      eval("monday_demo_#{i + 1}_with_tiles").should have(i + 1).tiles
    end

    # -------------------------------------

    Timecop.travel Date.today.beginning_of_week(:tuesday)
    demos = Demo.send_digest_email

    demos.should have(0).demos

    # -------------------------------------

    Timecop.travel Date.today.beginning_of_week(:wednesday)
    demos = Demo.send_digest_email

    demos.should have(0).demos

    # -------------------------------------

    Timecop.travel Date.today.beginning_of_week(:thursday)
    demos = Demo.send_digest_email

    demos.should have(0).demos

    # -------------------------------------

    Timecop.travel Date.today.beginning_of_week(:friday)
    demos = Demo.send_digest_email

    demos.should have(3).demos

    [friday_demo_1_with_tiles, friday_demo_2_with_tiles, friday_demo_3_with_tiles].each_with_index do |demo, i|
      demos.should include(demo)
      eval("friday_demo_#{i + 1}_with_tiles").should have(i + 1).tiles
    end

    # -------------------------------------

    Timecop.return
  end
end
