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
    expected = "#{demo.name} has 3 initiated connections, 1 of which have been accepted (33.333333333333336%)"
    demo.print_pending_friendships.should == expected


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

describe Demo, '#num_tile_completions' do
  it 'returns the number of users who have completed each of the tiles for this demo' do

    # Create some tile-completions (and thus users and tiles) that have nothing to do with this demo
    3.times { FactoryGirl.create :tile_completion }

    demo  = FactoryGirl.create :demo
    users = FactoryGirl.create_list :user, 9, demo: demo

    # Create some tiles that belong to this demo but that no users have completed
    tile_0   = FactoryGirl.create :tile, demo: demo
    tile_00  = FactoryGirl.create :tile, demo: demo
    tile_000 = FactoryGirl.create :tile, demo: demo

    # The status doesn't matter, but mix 'em up anyway just to show that it doesn't
    tile_1 = FactoryGirl.create :tile, demo: demo, status: Tile::ACTIVE
    tile_3 = FactoryGirl.create :tile, demo: demo, status: Tile::ARCHIVE
    tile_5 = FactoryGirl.create :tile, demo: demo, status: Tile::ACTIVE
    tile_7 = FactoryGirl.create :tile, demo: demo, status: Tile::ARCHIVE
    tile_9 = FactoryGirl.create :tile, demo: demo, status: Tile::ACTIVE


    1.times { |i| FactoryGirl.create :tile_completion, tile: tile_1,  user: users[i] }
    3.times { |i| FactoryGirl.create :tile_completion, tile: tile_3,  user: users[i] }
    5.times { |i| FactoryGirl.create :tile_completion, tile: tile_5,  user: users[i] }
    7.times { |i| FactoryGirl.create :tile_completion, tile: tile_7,  user: users[i] }
    9.times { |i| FactoryGirl.create :tile_completion, tile: tile_9,  user: users[i] }

    num_tile_completions = demo.num_tile_completions

    num_tile_completions[tile_1.id].should == 1
    num_tile_completions[tile_3.id].should == 3
    num_tile_completions[tile_5.id].should == 5
    num_tile_completions[tile_7.id].should == 7
    num_tile_completions[tile_9.id].should == 9

    [tile_0, tile_00, tile_000].each { |tile| num_tile_completions[tile.id].should be_nil }
  end
end

describe Demo, '#create_public_slug!' do
  it "should generate a slug based on the name" do
    d = Demo.create(name: "J.P. Patrick & His 999 Associates, Inc")
    d.reload.public_slug.should == "jp-patrick-his-999-associates-inc"
  end

  it "should handle duplication nicely" do
    name = 'Attack of the killer tomatoes'
    board_1 = Demo.create(name: name)
    board_2 = Demo.create(name: name + ' board') # an exact duplicate name isn't possible

    board_1.public_slug.should be_present
    board_2.public_slug.should be_present
    board_1.public_slug.should_not == board_2.public_slug
  end

  it "should lop off the word \"board\" if it appears at the end of the slug" do
    d = Demo.create(name: "The Extremely Serious Corporation Board")
    d.create_public_slug!
    d.reload.public_slug.should == "the-extremely-serious-corporation"
  end
end

describe Demo, 'on create' do
  it 'should set the public slug' do
    d = FactoryGirl.create(:demo)
    d.public_slug.should be_present
  end

  it "should send a ping" do
    d = FactoryGirl.create(:demo)
    crank_dj_clear

    FakeMixpanelTracker.should have_event_matching 'Board - New'
  end
end
