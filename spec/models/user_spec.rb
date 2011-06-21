require 'spec_helper'

describe User do
  before do
    Factory(:user)
  end

  it { should belong_to(:demo) }
  it { should have_many(:acts) }
  it { should have_many(:friendships) }
  it { should have_many(:friends).through(:friendships) }
  it { should have_many(:survey_answers) }
  it { should have_many(:wins) }

  it { should validate_presence_of(:name) }

  it { should validate_uniqueness_of(:slug) }

  it "should validate presence of the SMS slug on update" do
    user = Factory :user
    user.sms_slug.should_not be_nil # set by a callback on create
    user.should be_valid

    user.sms_slug = ''
    user.should_not be_valid
    user.errors[:sms_slug].should include("Sorry, you can't choose a blank unique ID.")
  end

  it "should validate uniqueness of phone number when not blank" do
    user1 = Factory :user, :phone_number => '+14152613077'
    user2 = Factory :user, :phone_number => ''
    user3 = Factory.build :user, :phone_number => '+14152613077'
    user4 = Factory.build :user, :phone_number => ''

    user1.should be_valid
    user2.should be_valid
    user3.should_not be_valid
    user4.should be_valid
  end

  it "should validate uniqueness of SMS slug when not blank" do
    user1 = Factory(:user)
    user2 = Factory(:user)
    user2.sms_slug = user1.sms_slug
    user2.should_not be_valid
  end
end

describe User, "#invitation_code" do
  before do
    Timecop.travel("1/1/11") do
      @user     = Factory(:user)
      @expected = Digest::SHA1.hexdigest("--#{Time.now.utc}--#{@user.email}--")
    end
  end

  it "should create unique invitation code" do
    @user.invitation_code.should == @expected
  end
end

describe User, ".alphabetical" do
  before do
    @jobs  = Factory(:user, :name => "Steve Jobs")
    @gates = Factory(:user, :name => "Bill Gates")
  end

  it "finds all users, sorted alphaetically" do
    User.alphabetical.should == [@gates, @jobs]
  end
end

describe User, ".claim_account" do
  before do
    @from       = "+14155551212"
    @claim_code = "gwendt17"
  end

  context "when no user with a matching claim code exists" do
    it "should return nil" do
      User.find_by_claim_code(@claim_code).should be_nil

      User.claim_account(@from, @claim_code).should be_nil
    end
  end

  context "when a user with a matching claim code exists" do
    before(:each) do
      @user = Factory :user, :claim_code => @claim_code
    end

    it "should set that user's phone number" do
      @user.phone_number.should be_blank
      @user.claim_code.should_not be_blank

      User.claim_account(@from, @claim_code)

      @user.reload
      @user.phone_number.should == @from
    end

    it "should return some text" do
      text_response = User.claim_account(@from, @claim_code)
      text_response.should be_a_kind_of(String)
      text_response.should_not be_blank
    end
  end
end

describe User, "#invite" do
  subject { Factory(:user) }

  context "when added to demo" do
    it { should_not be_invited }
  end

  context "when invited" do
    let(:invitation) { stub('invitation') }

    before do
      Mailer.stubs(:invitation => invitation)
      invitation.stubs(:deliver)
      subject.invite
    end

    it "sends invitation to user" do
      Mailer.should     have_received(:invitation).with(subject)
      invitation.should have_received(:deliver)
    end

    it { should be_invited }
  end
end

describe User, "#slug" do
  context "when John Smith is created" do
    before do
      @first = Factory(:user, :name => "John Smith")
    end

    it "has text-only slugs" do
      @first.slug.should == "John-Smith"
      @first.sms_slug.should == "jsmith"
    end

    context "and another John Smith is created" do
      before do
        @second = Factory(:user, :name => "John Smith")
      end

      it "has text-and-digit slugs" do
        @second.slug.should match(/^John-Smith-\d+$/)
        @second.sms_slug.should match(/^jsmith\d+$/)
      end

      context "and another John Smith is created" do
        before do
          @third = Factory(:user, :name => "John Smith")
        end

        it "has a unique text-and-digit slug" do
          @third.slug.should match(/^John-Smith-\d+$/)
          @third.sms_slug.should match(/^jsmith\d+$/)
          @third.slug.should_not == @second.slug
          @third.sms_slug.should_not == @second.sms_slug
        end
      end
    end
  end
end

describe User, '#generate_simple_claim_code!' do
  before(:each) do
    @first = Factory :user
  end

  it "should set the claim code" do
    @first.claim_code.should be_nil
    @first.generate_simple_claim_code!
    @first.claim_code.should_not be_nil
  end

  context "for multiple users with the same name" do
    before(:each) do
      @second = Factory :user, :name => @first.name
      @third = Factory :user, :name => @first.name
    end

    it "should generate the same claim codes" do
      @first.generate_simple_claim_code!
      @second.generate_simple_claim_code!
      @third.generate_simple_claim_code!

      @first.claim_code.should == @second.claim_code
      @first.claim_code.should == @third.claim_code
    end
  end

  context "for a user with middle names" do
    before(:each) do
      @first = Factory :user, :name => "Lyndon Baines Johnson"
      @second = Factory :user, :name => "Arthur Andrew Alabama Anderson"
      @third = Factory :user, :name => "Elizabeth II, Queen of England"
    end

    it "should use just first and last name" do
      @first.generate_simple_claim_code!
      @second.generate_simple_claim_code!
      @third.generate_simple_claim_code!

      @first.claim_code.should == 'ljohnson'
      @second.claim_code.should == 'aanderson'
      @third.claim_code.should == 'eengland'
    end
  end
end

describe User, '#generate_unique_claim_code!' do
  before(:each) do
    @first = Factory :user
  end

  it "should set the claim code" do
    @first.claim_code.should be_nil
    @first.generate_unique_claim_code!
    @first.claim_code.should_not be_nil
  end

  context "for multiple users with the same name" do
    before(:each) do
      @second = Factory :user, :name => @first.name
      @third = Factory :user, :name => @first.name
    end

    it "should generate unique claim codes" do
      @first.generate_unique_claim_code!
      @second.generate_unique_claim_code!
      @third.generate_unique_claim_code!

      @first.claim_code.should_not == @second.claim_code
      @first.claim_code.should_not == @third.claim_code
      @first.claim_code.should_not == @third.claim_code
    end
  end
end

share_examples_for "a ranking method" do
  before(:each) do
    @demo = Factory :demo
    10.downto(6) {|i| Factory :user, points_column => i, :demo => @demo}
    1.upto(4) {|i| Factory :user, points_column => i, :demo => @demo}
    @user = Factory :user, points_column => 5, :demo => @demo
  end

  context "when a user is created" do
    it "should set their ranking appropriately" do
      users_by_points = @demo.users.order("#{points_column} DESC").all
      users_by_points.map(&ranking_column).should == [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

      @user[ranking_column].should == 6
    end
  end

  context "when a user gains points" do
    it "should reset their ranking" do
      @user.send(update_points_method, 3)
      @user.reload[ranking_column].should == 3
    end

    it "should reset the ranking of all users who are now below them but weren't before" do
      @twin = Factory :user, points_column => 5, :demo => @demo
      @twin[ranking_column].should == @user[ranking_column]

      @user.send(update_points_method, 3)

      users_by_points = @demo.users.order("#{points_column} DESC").all
      users_by_points.map(&ranking_column).should == [1, 2, 3, 3, 5, 6, 7, 8, 9, 10, 11]
    end

    it "should work when breaking ties" do
      User.delete_all
      @first = Factory :user, points_column => 10, :demo => @demo
      @second = Factory :user, points_column => 10, :demo => @demo
      @third = Factory :user, points_column => 10, :demo => @demo

      @first.reload[ranking_column].should == @second[ranking_column]
      @first.reload[ranking_column].should == @third.reload[ranking_column]

      @first.send(update_points_method, 1)
      @first.reload[ranking_column].should == 1
      @second.reload[ranking_column].should == 2
      @third.reload[ranking_column].should == 2
    end
  end
end

describe User, "#update_recent_average_points" do
  # The correct formula to calculate the actual point gain is
  # A = ceil(P * (D + 1) / sum(1..D + 1)) where
  # A is the actual point gain,
  # P is the nominal point gain (i.e. the unweighted amount as added to the full score),
  # D is the depth of the history (0 <= D <= 6).
  # 
  # For the values of D we're concerned with, we multiply A by the factor below
  # and round up to the next integer:
  #
  # D = 0: Factor of 1
  # D = 1: Factor of 2/3
  # D = 2: Factor of 1/2
  # D = 3: Factor of 2/5
  # D = 4: Factor of 1/3
  # D = 5: Factor of 2/7
  # D = 6: Factor of 1/4
  [
    [0,1,1], [0,2,2], [0,3,3],
    [1,1,1], [1,2,2], [1,3,2], [1,4,3], [1,5,4],
    [2,1,1], [2,2,1], [2,3,2], [2,4,2], [2,5,3],
    [3,1,1], [3,2,1], [3,3,2], [3,4,2], [3,5,2], [3,6,3],
    [4,1,1], [4,2,1], [4,3,1], [4,4,2], [4,5,2], [4,6,2], [4,7,3],
    [5,1,1], [5,2,1], [5,3,1], [5,4,2], [5,5,2], [5,6,2], [5,7,2], [5,8,3],
    [6,1,1], [6,2,1], [6,3,1], [6,4,1], [6,5,2], [6,6,2], [6,7,2], [6,8,2], [6,9,3]
  ].each do |history_depth, points_added, expected_point_gain|
    it "should increase #recent_average_points by #{expected_point_gain} points when adding #{points_added} points and history depth is #{history_depth}" do
      user = Factory :user, :recent_average_history_depth => history_depth
      user.update_recent_average_points(points_added)

      user.reload.recent_average_points.should == expected_point_gain
    end
  end
end

describe User, "#ranking" do
  let(:points_column) {:points}
  let(:ranking_column) {:ranking}
  let(:update_points_method) {:update_points}

  it_should_behave_like 'a ranking method'
end

describe User, "#recent_average_ranking" do
  let(:points_column) {:recent_average_points}
  let(:ranking_column) {:recent_average_ranking}
  let(:update_points_method) {:update_recent_average_points}

  it_should_behave_like 'a ranking method'
end

describe User, "#recalculate_moving_average!" do
  before(:each) do
    Timecop.freeze(Time.parse('2011-05-01 00:05 -0500'))
  end

  after(:each) do
    Timecop.return
  end

  context "for a user with no acts" do
    it "should leave their recent_average_history_depth at 0" do
      user = Factory :user
      user.recalculate_moving_average!
      user.reload.recent_average_history_depth.should == 0
    end
  end

  context "for a user with an act today but none in the past" do
    it "should leave their recent_average_history_depth at 0" do
      user = Factory :user
      Factory :act, :user => user, :created_at => Date.today.midnight + 1.minute

      user.recalculate_moving_average!
      user.reload.recent_average_history_depth.should == 0
    end
  end

  1.upto(User::MAX_RECENT_AVERAGE_HISTORY_DEPTH) do |expected_history_depth|
    context "for a user with earliest act #{expected_history_depth} days ago" do
      it "should set their recent_average_history_depth to #{expected_history_depth}" do
        user = Factory :user

        # Guaranteed to have at least one act expected_history_depth days ago
        Factory :act, :user => user, :created_at => sometime_on(expected_history_depth.days.ago)

        # Might have some more recent acts too
        expected_history_depth.downto(1) do |past_day_offset|
          rand(5).times {Factory :act, :user => user, :created_at => sometime_on(past_day_offset.days.ago)}
        end

        user.recalculate_moving_average!
        user.reload.recent_average_history_depth.should == expected_history_depth
      end
    end
  end

  context "for a user with an act #{User::MAX_RECENT_AVERAGE_HISTORY_DEPTH} days ago and one #{User::MAX_RECENT_AVERAGE_HISTORY_DEPTH + 1} days ago" do
    it "should set their recent_average_history_depth to #{User::MAX_RECENT_AVERAGE_HISTORY_DEPTH}" do
      user = Factory :user
      Factory :act, :user => user, :created_at => sometime_on(User::MAX_RECENT_AVERAGE_HISTORY_DEPTH.days.ago)
      Factory :act, :user => user, :created_at => sometime_on((User::MAX_RECENT_AVERAGE_HISTORY_DEPTH + 1).days.ago)

      user.recalculate_moving_average!
      user.reload.recent_average_history_depth.should == User::MAX_RECENT_AVERAGE_HISTORY_DEPTH
    end
  end

  context "for a user with all acts more than #{User::MAX_RECENT_AVERAGE_HISTORY_DEPTH} days ago" do
    it "should set their recent_average_history_depth to 0" do
      user = Factory :user
      1.upto(10) do |days_beyond_horizon|
        3.times {Factory :act, :user => user, :created_at => sometime_on((User::MAX_RECENT_AVERAGE_HISTORY_DEPTH + days_beyond_horizon).days.ago)}
      end

      user.recalculate_moving_average!
      user.reload.recent_average_history_depth.should == 0
    end
  end

  {
    [] => 0,
    [[0, 10]] => 10,
    [[0, 10], [0, 15]] => 25,
    [[0, 10], [1, 14]] => 12,
    [[0, 10], [0, 15], [1, 7], [1, 12], [2, 6]] => 20,
    [[1, 7], [1, 12], [2, 6]] => 8,
    [[0, 7], [0, 12], [2, 6]] => 11
  }.each do |act_signatures, expected_score|
    context "for a user with recent act signatures #{act_signatures}" do
      it "should set their recent_average_points to #{expected_score}" do
        user = Factory :user
        act_signatures.each do |days_ago, points|
          Factory :act, :user => user, :inherent_points => points, :created_at => sometime_on(Date.today - days_ago.days)
        end

        user.recalculate_moving_average!
        user.reload.recent_average_points.should == expected_score
      end
    end
  end

  it "should ignore acts that took place in a Demo other than the current one" do
    user = Factory :user
    Factory :act, :user => user, :inherent_points => 10
    Factory :act, :user => user, :inherent_points => 3, :demo_id => (Factory :demo).id, :created_at => Date.yesterday.midnight

    user.recalculate_moving_average!
    user.reload

    user.recent_average_history_depth.should == 0
    user.recent_average_points.should == 10
  end

  it "should not touch the user's recent average ranking" do
    user = Factory :user, :recent_average_points => 100000
    user.update_attribute(:recent_average_ranking, 1000)
    user.reload.recent_average_ranking.should == 1000

    user.recalculate_moving_average!
    user.reload.recent_average_ranking.should == 1000
  end

end

describe User, "on save" do
  it "should downcase email" do
    @user = Factory.build(:user, :email => 'YELLING_GUY@Uppercase.cOm')
    @user.save!
    @user.reload.email.should == 'yelling_guy@uppercase.com'
  end
end

describe User, "#move_to_new_demo" do
  before(:each) do
    @user = Factory :user
    @new_demo = Factory :demo
  end

  describe "when the user has acts (plural) in the new demo with nil points" do
    before(:each) do
      2.times do
        act = Factory :act, :user => @user, :demo_id => @new_demo.id, :created_at => Date.today
        act.points.should be_nil
      end
    end

    it "should not raise an exception" do
      lambda{@user.move_to_new_demo(@new_demo.id)}.should_not raise_exception
      @user.reload.points.should == 0
    end
  end
end

describe User, "#credit_referring_user" do
  before :each do
    Twilio::SMS.stubs(:create)

    @user = Factory :user
    @rule_value = Factory :rule_value
    @referring_user = Factory :user
  end

  it "should create an Act with the appropriate values" do
    @user.send(:credit_referring_user, @referring_user, @rule_value.rule, @rule_value)

    latest_act = @referring_user.reload.acts.last
    latest_act.text.should include(@user.name)
    latest_act.text.should include(@rule_value.value)
    latest_act.inherent_points.should == @rule_value.rule.points / 2
  end

  describe "when the referring user has no phone number" do
    before :each do
      @referring_user.phone_number.should be_blank
    end

    it "should not try to send an SMS to that blank number" do
      @user.send(:credit_referring_user, @referring_user, @rule_value.rule, @rule_value)

      Twilio::SMS.should_not have_received(:create)
    end
  end
end

describe "#join_game" do
  before(:each) do
    @user = Factory :user
    Timecop.freeze
  end

  after(:each) do
    Timecop.return
  end

  it "should set the user's accepted_invitation_at timestamp" do
    @user.accepted_invitation_at.should be_nil
    @user.join_game '+14158675309'
    @user.reload.accepted_invitation_at.should == Time.now
  end
end

