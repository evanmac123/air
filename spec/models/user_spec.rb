require 'spec_helper'

describe User do
  before do
    FactoryGirl.create(:user)
  end

  it { should have_one(:demo) }
  it { should have_many (:demos) }
  it { should belong_to(:location) }
  it { should have_many(:acts) }
  it { should have_many(:friendships) }
  it { should have_many(:friends).through(:friendships) }
  it { should have_many(:tile_completions) }
  it { should have_many(:tiles) }
  # Note that our validates_uniqueness_of :email is called in the Clearance gem
  it { should validate_uniqueness_of(:email) }
  it { should validate_presence_of(:name).with_message("Please enter a first and last name") }

end

describe User do
  before do
    User.delete_all
    ActionMailer::Base.deliveries.clear
  end

  it { should validate_presence_of :privacy_level }

  it "should validate that privacy level is set to a valid value" do
    user = FactoryGirl.create :user
    user.should be_valid

    User::PRIVACY_LEVELS.each do |privacy_level|
      user.privacy_level = privacy_level
      user.should be_valid

      user.privacy_level = privacy_level + "foo"
      user.should_not be_valid
    end
  end

  it "should validate uniqueness of phone number when not blank" do
    user1 = FactoryGirl.create :user, :phone_number => '+14152613077'
    user2 = FactoryGirl.create :user, :phone_number => ''
    user3 = FactoryGirl.build :user, :phone_number => '+14152613077'
    user4 = FactoryGirl.build :user, :phone_number => ''
    user5 = FactoryGirl.build :user, :phone_number => "(415) 261-3077"

    user1.should be_valid
    user2.should be_valid
    user3.should_not be_valid
    user4.should be_valid
    user5.should_not be_valid

    user3.errors[:phone_number].should == ["Sorry, but that phone number has already been taken. Need help? Contact support@air.bo"]
  end

  it 'should validate 5-digit zipcode' do
    user = FactoryGirl.build :user
    user.should be_valid  # no zipcode is okay

    user.zip_code = 'xxxxx'
    user.should_not be_valid

    user.zip_code = '12345-6789'
    user.should_not be_valid

    user.zip_code = '12345'
    user.should be_valid
  end

  it "should validate uniqueness of SMS slug when not blank" do
    user1 = FactoryGirl.create(:claimed_user)
    user2 = FactoryGirl.create(:claimed_user)
    user2.sms_slug = user1.sms_slug
    user2.should_not be_valid
  end

  it "should validate that the SMS slug, if not blank, consists of all letters and digits" do
    user = FactoryGirl.create :claimed_user
    user.should be_valid

    user.sms_slug = "i rule"
    user.should_not be_valid
    user.errors[:sms_slug].should == ["Sorry, the username must consist of letters or digits only."]

    user.sms_slug = "i!rule"
    user.should_not be_valid
    user.errors[:sms_slug].should == ["Sorry, the username must consist of letters or digits only."]

    user.sms_slug = "irule23times"
    user.should be_valid
  end

  it "should validate that date of birth, if present, is in the past" do
    Timecop.freeze(Time.now)

    begin
      user = FactoryGirl.create :claimed_user
      user.should be_valid

      user.date_of_birth = Date.today
      user.should_not be_valid
      user.errors.full_messages.should include("Date of birth must be in the past")

      user.date_of_birth = Date.yesterday
      user.should be_valid
    ensure
      Timecop.return
    end
  end

  it "should downcase an SMS slug before validation" do
    user1 = FactoryGirl.create :user
    user1.update_attributes(:sms_slug => "somedude")

    user2 = FactoryGirl.create :claimed_user
    user2.should be_valid

    user2.sms_slug = 'SomeDude'
    user2.should_not be_valid
    user2.errors[:sms_slug].should == ["Sorry, that username is already taken."]
    user3 = FactoryGirl.create :user
    user3.update_attributes(:sms_slug => "OtherDude")
    user3.reload.sms_slug.should == "otherdude"
  end

  it "should allow multiple users, each with the same (blank) sms slugs" do
    FactoryGirl.create(:user, :sms_slug => '')
    user = FactoryGirl.build(:user, :sms_slug => '')
    user.should be_valid
  end

  describe "on create" do
    it "should set their explore_token" do
      user = FactoryGirl.create(:user)
      user.explore_token.should be_present
    end
  end

  describe "on destroy" do
    it "should destroy any Friendships where this user is the friend on destroy" do
      user1 = FactoryGirl.create(:user)
      user2 = FactoryGirl.create(:user)
      Friendship.create!(:user => user1, :friend => user2)

      user2.destroy
      user1.reload.friendships.should be_empty
    end
  end
end

describe User do
  before do
    User.delete_all
  end

  it "should not require a slug if there is no name" do
    # That way, there's only the one error if the name is blank
    a = FactoryGirl.build(:user, :name => "")
    a.should_not be_valid
    a.errors[:slug].should be_empty
    a.errors[:sms_slug].should be_empty
  end

  it "should create a slug upon validation if there is a name" do
    a = FactoryGirl.build(:user, :name => "present")
    a.should be_valid   # Slugs generated before_validation
    a.slug.should == "present"
    a.sms_slug.should == "present"
  end

  it "should create slugs when you create" do
    a = FactoryGirl.create(:user, :name => "present")
    a.slug.should == "present"
    a.sms_slug.should == "present"
  end

  it "should validate the uniqueness of :slug if name is present" do
    a = FactoryGirl.build(:user, :name =>"present", :slug => "areallylongstring", :sms_slug => "areallylongstring")
    a.should be_valid
    a.save
    bb = FactoryGirl.build(:user, :name =>"present", :slug => "areallylongstring", :sms_slug => "areallylongstring")
    bb.should_not be_valid # since slugs are already present, set_slugs will not be called
    bb.errors[:slug].should include("has already been taken")
    bb.errors[:sms_slug].should include("Sorry, that username is already taken.")
  end
end



describe User, "#update_password" do
  context "when called with blank password and confirmation" do
    # We can't just validate_presence_of :password since sometimes a blank
    # password is valid and it's tricky to sum up those cases in one method on
    # User. But #update_password should never let a blank password be set.

    it "should return false and not update" do
      user = FactoryGirl.create :user
      user.password = "foobar"
      user.save!

      user.update_password("").should == false
      user.password.should == "foobar"
    end
  end
end

describe User, "#invitation_code" do
  before do
    Timecop.freeze("1/1/11") do
      @user     = FactoryGirl.create(:user)
      @expected = Digest::SHA1.hexdigest("--#{Time.now.to_f}--#{@user.email}--#{@user.name}--")
    end
  end

  after do
    Timecop.return
  end

  it "should create unique invitation code" do
    @user.invitation_code.should == @expected
  end

  context "when invitation code is not blank" do
    it "should validate uniqueness" do
      user1 = FactoryGirl.create(:user)
      user2 = FactoryGirl.create(:user)

      user1.invitation_code.should_not be_blank
      user2.should be_valid

      user2.invitation_code = user1.invitation_code
      user2.should_not be_valid
    end
  end
end

describe User, '#set_invitation_code' do
  it "should retry until unique" do
    first_code = "asdasdasdasdasd"
    second_code = "qweqweqweqweqwe"

    user1 = FactoryGirl.create(:user)
    user2 = FactoryGirl.create(:user)

    user1.update_attributes(invitation_code: first_code)

    Digest::SHA1.stubs(:hexdigest).returns(first_code, second_code)

    user2.set_invitation_code

    user2.invitation_code.should == second_code
    user2.should be_valid
    Digest::SHA1.should have_received(:hexdigest).twice
  end
end

describe User, ".alphabetical" do
  before do
    User.delete_all
    @jobs  = FactoryGirl.create(:user, :name => "Steve Jobs")
    @gates = FactoryGirl.create(:user, :name => "Bill Gates")
  end

  it "finds all users, sorted alphaetically" do
    User.alphabetical.should == [@gates, @jobs]
  end
end

describe User, "#invite" do
  subject { FactoryGirl.create(:user) }

  context "when added to demo" do
    it { should_not be_invited }
  end

  context "when invited" do
    let(:invitation) { stub('invitation') }

    before do
      Mailer.stubs(:invitation => invitation)
      invitation.stubs(:deliver)
      subject.invite
      crank_dj_clear
    end

    it "sends invitation to user" do
      Mailer.should     have_received(:invitation).with(subject, nil, {})
      invitation.should have_received(:deliver)
    end

    it { should be_invited }
  end

  context "when no referrer is given" do
    it "should not record a PeerInvitation" do
      PeerInvitation.count.should == 0
      subject.invite

      PeerInvitation.count.should == 0
    end
  end

  context "when a referrer is given" do
    it "should record a PeerInvitation" do
      other_user = FactoryGirl.create(:user)

      PeerInvitation.count.should == 0
      subject.invite(other_user)

      PeerInvitation.count.should == 1

      invitation = PeerInvitation.first
      invitation.inviter.should == other_user
      invitation.invitee.should == subject
      invitation.demo.should == other_user.demo
    end

    context "and the user already has #{PeerInvitation::CUTOFF} invitations" do
      before(:each) do
        PeerInvitation::CUTOFF.times {FactoryGirl.create(:peer_invitation, invitee: subject, demo: subject.demo)}
        subject.reload.peer_invitations_as_invitee.count.should == PeerInvitation::CUTOFF

        other_user = FactoryGirl.create(:user)
        subject.invite(other_user)
        crank_dj_clear
      end

      it "should not send another invitation email" do
        ActionMailer::Base.deliveries.should be_empty
      end

      it "should not record another PeerInvitation" do
        subject.reload.peer_invitations_as_invitee.count.should == PeerInvitation::CUTOFF
      end
    end
  end
end

describe User, "#slug" do
  context "when John Smith is created" do
    before do
      @first = FactoryGirl.create(:user, :name => "John Smith")
    end

    it "has text-only slugs" do
      @first.slug.should == "johnsmith"
      @first.sms_slug.should == "johnsmith"
    end

    context "and another John Smith is created" do
      before do
        @second = FactoryGirl.create(:user, :name => "John Smith")
      end

      it "has text-and-digit slugs" do
        @second.slug.should match(/^johnsmith\d+$/)
        @second.sms_slug.should match(/^johnsmith\d+$/)
      end

      context "and another John Smith is created" do
        before do
          @third = FactoryGirl.create(:user, :name => "John Smith")
        end

        it "has a unique text-and-digit slug" do
          @third.slug.should match(/^johnsmith\d+$/)
          @third.sms_slug.should match(/^johnsmith\d+$/)
          @third.slug.should_not == @second.slug
          @third.sms_slug.should_not == @second.sms_slug
        end
      end
    end
  end
end

describe User, '#generate_simple_claim_code!' do
  before(:each) do
    @first = FactoryGirl.create :user
  end

  it "should set the claim code" do
    @first.claim_code.should be_nil
    @first.generate_simple_claim_code!
    @first.claim_code.should_not be_nil
  end

  context "for multiple users with the same name" do
    before(:each) do
      @second = FactoryGirl.create :user, :name => @first.name
      @third = FactoryGirl.create :user, :name => @first.name
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
      @first = FactoryGirl.create :user, :name => "Lyndon Baines Johnson"
      @second = FactoryGirl.create :user, :name => "Arthur Andrew Alabama Anderson"
      @third = FactoryGirl.create :user, :name => "Elizabeth II, Queen of England"
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
    @first = FactoryGirl.create :user
  end

  it "should set the claim code" do
    @first.claim_code.should be_nil
    @first.generate_unique_claim_code!
    @first.claim_code.should_not be_nil
  end

  context "for multiple users with the same name" do
    before(:each) do
      @second = FactoryGirl.create :user, :name => @first.name
      @third = FactoryGirl.create :user, :name => @first.name
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

describe User, "on create" do
  it "should create an associated segmentation info record in mongo" do
    @user = FactoryGirl.create :user
    crank_dj_clear

    @user.segmentation_data.should be_present
  end

  it "should has_own_tile_completed equal to false" do
    @user = FactoryGirl.create :user

    @user.has_own_tile_completed.should be_false
  end
end

describe User, "on save" do
  it "should downcase email" do
    @user = FactoryGirl.build(:user, :email => 'YELLING_GUY@Uppercase.cOm')
    @user.save!
    @user.reload.email.should == 'yelling_guy@uppercase.com'
  end

  describe 'spousal relationship synchronization' do
    let(:member) { FactoryGirl.create :user }

    describe 'on create' do
      it 'should not link spouse if not specfied' do
        user = FactoryGirl.create :user
        member.reload.spouse_id.should be_nil
      end

      it 'should link spouse if specfied' do
        user = FactoryGirl.create :user, spouse_id: member.id
        member.reload.spouse_id.should == user.id
      end
    end

    describe 'on update' do
      let(:user) { FactoryGirl.create :user }

      it 'should not link spouse if other field updated' do
        user.update_attribute :name, "Fred Flintstone"
        member.reload.spouse_id.should be_nil
      end

      it 'should link spouse if specfied' do
        member.reload.spouse_id.should be_nil

        user.update_attribute :spouse_id, member.id
        member.reload.spouse_id.should == user.id
      end

      it 'should unlink spouse if nullified' do
        user = FactoryGirl.create :user, spouse_id: member.id
        member.reload.spouse_id.should == user.id

        user.update_attribute :spouse_id, nil
        member.reload.spouse_id.should be_nil
      end
    end
  end

  it "should parse characteristics according to the datatypes" do
    user = FactoryGirl.build :user

    discrete_characteristic = FactoryGirl.create :characteristic, :datatype => Characteristic::DiscreteType, :allowed_values => %w(foo bar baz)
    number_characteristic = FactoryGirl.create :characteristic, :datatype => Characteristic::NumberType
    date_characteristic = FactoryGirl.create :characteristic, :datatype => Characteristic::DateType
    boolean_characteristic = FactoryGirl.create :characteristic, :datatype => Characteristic::BooleanType

    user.characteristics = {
      discrete_characteristic.id => 'foo',
      number_characteristic.id   => '27.3',
      date_characteristic.id     => Chronic.parse("March 1, 2009").to_s,
      boolean_characteristic.id  => '1'
    }

    user.save!
    user.reload

    user.characteristics[discrete_characteristic.id].should == 'foo'
    user.characteristics[number_characteristic.id].should == 27.3
    user.characteristics[date_characteristic.id].should == Chronic.parse("March 1, 2009").to_date
    user.characteristics[boolean_characteristic.id].should == true
  end

  def check_for_segmentation_update(field_name, old_value, new_value, expected_values=[])
    expected_old_value = expected_values.first || old_value
    expected_new_value = expected_values.last || new_value

    user = FactoryGirl.create(:user, field_name => old_value)
    crank_dj_clear
    user.segmentation_data[field_name].should == expected_old_value

    user.update_attributes(field_name => new_value)
    crank_dj_clear
    user.segmentation_data.reload.send(field_name).should == expected_new_value
  end

  simple_mongo_triggering_fields = {
    points:                 [50, 60],
    location_id:            [17, 18],
    date_of_birth:          [Date.yesterday, Date.yesterday.yesterday, [Date.yesterday.to_time.utc.midnight, Date.yesterday.yesterday.to_time.utc.midnight]],
    gender:                 ['male', 'female']
  }

  simple_mongo_triggering_fields.each do |field_name, values|
    context "when #{field_name} is changed" do
      it "should sync to mongo" do
        check_for_segmentation_update(field_name, *values)
      end
    end
  end

  it "should sync to mongo when characteristics is changed" do
    user = FactoryGirl.create(:user)
    characteristic = FactoryGirl.create(:characteristic, :allowed_values => %w(foo bar baz))
    crank_dj_clear
    user.segmentation_data.characteristics.should == {}

    user.characteristics = {characteristic.id => 'foo'}
    user.save
    crank_dj_clear
    user.segmentation_data.characteristics.should == {characteristic.id => 'foo'}.stringify_keys
  end

  it "should sync to mongo when a user is added to a board" do
    user = FactoryGirl.create(:user)
    first_demo = user.demo
    second_demo = FactoryGirl.create(:demo)

    crank_dj_clear
    user.segmentation_data.demo_ids.should == [first_demo.id]

    user.add_board(second_demo)
    crank_dj_clear
    user.segmentation_data.demo_ids.sort.should == [first_demo.id, second_demo.id].sort
  end

  it "should sync to mongo when a user acts" do
    user = FactoryGirl.create :user
    crank_dj_clear
    user.segmentation_data.last_acted_at.should be_nil
    act = FactoryGirl.create(:act, user: user)
    crank_dj_clear
    now = Time.now
    user.segmentation_data.last_acted_at.should_not be_nil
  end

  it "should sync to mongo when accepted_invitation_at is changed, updating the value of claimed too" do
    user = FactoryGirl.create :user
    crank_dj_clear
    user.segmentation_data.accepted_invitation_at.should be_nil
    user.segmentation_data.claimed.should be_false

    accept_time = Chronic.parse("May 1, 2012, 3:00 PM")
    user.accepted_invitation_at = accept_time
    user.save!
    crank_dj_clear
    user.segmentation_data.accepted_invitation_at.should == accept_time.utc
    user.segmentation_data.claimed should be_true
  end

  it "should sync to mongo whether or not the user has a phone number on record" do
    user = FactoryGirl.create :user
    crank_dj_clear
    user.segmentation_data.has_phone_number.should be_false

    user.phone_number = "+14155551212"
    user.save!
    crank_dj_clear
    user.segmentation_data.has_phone_number.should be_true

    user.phone_number = ""
    user.save!
    crank_dj_clear
    user.segmentation_data.has_phone_number.should be_false
  end
end

describe User, "on destroy" do
  it "should destroy the associated mongo data" do
    user = FactoryGirl.create :user
    crank_dj_clear
    User::SegmentationData.where(:ar_id => user.id).count.should == 1

    user.destroy
    crank_dj_clear
    User::SegmentationData.where(:ar_id => user.id).count.should == 0
  end
end

describe User, "#move_to_new_demo" do
  before(:each) do
    @user = FactoryGirl.create :user
    @new_demo = FactoryGirl.create :demo
  end

  context "when the user belongs to the new demo" do
    before do
      @user.add_board @new_demo
    end

    it "should set that as their current demo" do
      @user.move_to_new_demo(@new_demo)
      @user.reload.demo.should == @new_demo
    end

    it "should leave them with one current board" do
      @user.move_to_new_demo(@new_demo)
      @user.board_memberships.where(is_current: true).should have(1).board
    end

    it "should keep the value of their board-specific fields consistent with the BoardMembership corresponding to the board they move into" do
      original_demo = @user.demo
      original_location = FactoryGirl.create(:location, demo: original_demo)
      @user.is_client_admin = true
      @user.points = 43
      @user.ticket_threshold_base = 21
      @user.tickets = 1
      @user.location = original_location
      @user.save

      @user.move_to_new_demo @new_demo
      @user.reload.is_client_admin.should be_false
      @user.reload.points.should == 0
      @user.reload.ticket_threshold_base.should == 0
      @user.reload.tickets.should == 0
      @user.reload.location.should be_nil

      @user.move_to_new_demo original_demo
      @user.reload.is_client_admin.should be_true
      @user.reload.points.should == 43
      @user.reload.ticket_threshold_base.should == 21
      @user.reload.tickets.should == 1
      @user.reload.location.should == original_location
    end
  end

  context "when the user does not belong to that demo" do
    before do
      @user.demos.should_not include(@new_demo)
    end

    it "should leave them unmoved" do
      @user.move_to_new_demo(@new_demo)
      @user.reload.demo.should_not == @new_demo
    end

    it "should leave them with one current board" do
      @user.move_to_new_demo(@new_demo)
      @user.board_memberships.where(is_current: true).should have(1).board
    end

    context "but is a site admin" do
      before do
        @user.is_site_admin = true
        @user.save!
      end

      it "adds 'em and moves them in" do
        @user.move_to_new_demo(@new_demo)
        @user.reload.demo.should == @new_demo
        @user.demos.should have(2).demos
      end

      it "should leave them with one current board" do
        @user.move_to_new_demo(@new_demo)
        @user.board_memberships.where(is_current: true).should have(1).board
      end
    end
  end
end

describe User, "#add_board" do
  it "should be idempotent, i.e. not create redundant BoardMemberships if called more than once with the same arguments" do
    user = FactoryGirl.create(:user)
    user.board_memberships.length.should == 1

    board = FactoryGirl.create(:demo)

    user.add_board(board)
    user.add_board(board)

    user.board_memberships.length.should == 2
    user.board_memberships.where(demo_id: board.id).length.should == 1
  end
end

describe User, "#credit_referring_user" do
  before :each do
    Twilio::SMS.stubs(:create)

    @user = FactoryGirl.create :user
    @rule_value = FactoryGirl.create :rule_value
    @referring_user = FactoryGirl.create :user
  end

  it "should create an Act with the appropriate values" do
    @user.send(:credit_referring_user, @referring_user, @rule_value.rule, @rule_value)

    latest_act = @referring_user.reload.acts.last
    latest_act.text.should include(@user.name)
    latest_act.text.should_not include(@rule_value.value)
    latest_act.inherent_points.should == @rule_value.rule.points / 2
  end

  describe "when the referring user has no phone number" do
    before :each do
      @referring_user.phone_number.should be_blank
    end

    it "should not try to send an SMS to that blank number" do
      @user.send(:credit_referring_user, @referring_user, @rule_value.rule, @rule_value)

      Twilio::SMS.should have_received(:create).never
    end
  end
end

describe "#mark_as_claimed" do
  before(:each) do
    @user = FactoryGirl.create :user
    Timecop.freeze(1)
  end

  after(:each) do
    Timecop.return
  end

  context "when called with a phone number" do
    it "should set the user's accepted_invitation_at timestamp" do
      @user.accepted_invitation_at.should be_nil
      @user.mark_as_claimed(:phone_number => '+14158675309')
      @user.reload.accepted_invitation_at.to_s.should == ActiveSupport::TimeZone['Eastern Time (US & Canada)'].now.to_s
    end
  end

  context "when called with an email address" do
    it "should set the user's accepted_invitation_at timestamp" do
      @user.accepted_invitation_at.should be_nil
      @user.mark_as_claimed(:email => 'bob@gmail.com')
      @user.reload.accepted_invitation_at.to_s.should == ActiveSupport::TimeZone['Eastern Time (US & Canada)'].now.to_s
    end
  end
end

describe User, "generates a validation token" do
  it "should generate a token" do
    a = FactoryGirl.create(:user, :email => "a@a.com")
    a.reload.new_phone_validation.should be_blank
    a.generate_short_numerical_validation_token
    field = a.reload.new_phone_validation
    field.should_not be_blank
    (field =~ /^\d{4}$/).should_not be_nil
  end
end

describe User, "reset_all_mt_texts_today_counts!" do
  it "should reset MT text count on all users" do
    20.times {FactoryGirl.create :user, :mt_texts_today => rand(1000)}
    User.reset_all_mt_texts_today_counts!
    User.where(:mt_texts_today => 0).count.should == User.count
  end
end

describe User, "#schedule_followup_welcome_message" do
  it "should only send a message once" do
    SMS.stubs(:send_message)

    demo = FactoryGirl.create :demo, :followup_welcome_message => "hey hey", :followup_welcome_message_delay => 0
    user = FactoryGirl.create :user, :phone_number => "+14155551212", :demo => demo, :notification_method => :both

    2.times {user.schedule_followup_welcome_message}
    crank_dj_clear
    SMS.should have_received(:send_message).once
  end
end

describe User do
  describe "Privacy Settings" do
    it "should allow anyone to view the activity of a user whose privacy status is 'everybody'" do
      follower = FactoryGirl.create :user
      artist = FactoryGirl.create(:user, :privacy_level => "everybody")
      follower.can_see_activity_of(artist).should == true
    end
  end
end

describe User, "#sms_slug_does_not_match_commands" do
  it "should invalidate user if sms_slug matches a command" do
    demo = FactoryGirl.create(:demo, :name => "my_demo")
    rule = FactoryGirl.create(:rule, :demo => demo)
    rule_value = FactoryGirl.create(:rule_value, :value => "hippa", :rule_id => rule.id)
    user = FactoryGirl.build(:user, :demo => demo, :sms_slug => 'follow', :slug => 'follow')
    user.should_not be_valid
    user = FactoryGirl.build(:user, :demo => demo, :sms_slug => 'hippa', :slug => 'hippa')
    user.should_not be_valid
    user = FactoryGirl.build(:user, :demo => demo, :sms_slug => 'followmehome', :slug => 'followmehome')
    user.should be_valid
  end
end

describe User, "#befriend" do
  before(:each) do
    @demo = FactoryGirl.create(:demo, :name => "It's just a game")
    @left_user = FactoryGirl.create(:claimed_user, :name => "Lefty Loosey", :demo => @demo)
    @right_user = FactoryGirl.create(:claimed_user, :name => "Righty Tighty", :demo => @demo)
  end

  it "should create two friendships, one initiated and one pending" do
    # Befriend
    @left_user.befriend(@right_user)
    # Verify two friendships created, one initiated--one pending
    first_friendship_array = Friendship.where(:user_id => @left_user.id, :friend_id => @right_user.id)
    first_friendship_array.length.should == 1
    first_friendship = first_friendship_array.first
    first_friendship.state.should == "initiated"
    second_friendship_array = Friendship.where(:user_id => @right_user.id, :friend_id => @left_user.id)
    second_friendship_array.length.should == 1
    second_friendship = second_friendship_array.first
    second_friendship.state.should == "pending"
  end

  it "accepting friendship should make both frienships show up accepted" do
    # Befriend
    @left_user.befriend(@right_user)
    # Verify two friendships created, one initiated--one pending
    initiated_friendship = Friendship.where(:user_id => @left_user.id, :friend_id => @right_user.id).first
    pending_friendship = Friendship.where(:user_id => @right_user.id, :friend_id => @left_user.id).first
    initiated_friendship.accept
    initiated_friendship.reload.state.should == "accepted"
    pending_friendship.reload.state.should == "accepted"
  end

  it "each shows up as each other friend using the .friends construct" do
    # Befriend
    @left_user.befriend(@right_user)

    @left_user.initiated_friends.length.should == 1
    @right_user.initiated_friends.should be_empty
    @right_user.pending_friends.length.should == 1
    @left_user.pending_friends.should be_empty
  end

  it "each shows up as each other friend using the .friends construct" do
    # Befriend
    @left_user.befriend(@right_user)
    initiated_friendship = Friendship.where(:user_id => @left_user.id, :friend_id => @right_user.id).first
    initiated_friendship.accept
    # Should be no more pending friends
    @left_user.pending_friends.should be_empty
    @right_user.pending_friends.should be_empty
    # Each should have one real friend
    @left_user.friends.length.should == 1
    @right_user.friends.length.should == 1
  end

  it "should ping Mixpanel" do
    @left_user.befriend(@right_user, :channel => :web)
    crank_dj_clear
    FakeMixpanelTracker.should have_event_matching("fanned", @left_user.data_for_mixpanel.merge(:channel => :web))
  end
end

describe User do
  it "should not allow any duplicate email addresses across 'email' or 'overflow_email'" do
    first_email = '123@hi.com'
    second_email = '456@hi.com'
    third_email = 'something_crafty@sexy.com'
    FactoryGirl.create(:user, email: first_email, overflow_email: second_email)
    @user2 = FactoryGirl.build(:user, name: 'henry')
    @user2.should be_valid
    @user2.email = first_email
    @user2.should_not be_valid
    @user2.email = second_email
    @user2.should_not be_valid
    @user2.email = 'way@different.com'
    @user2.should be_valid
    @user2.overflow_email = first_email
    @user2.should_not be_valid
    @user2.overflow_email = second_email
    @user2.should_not be_valid
    @user10 = FactoryGirl.build(:user, email: third_email, overflow_email: third_email)
    @user10.should_not be_valid
  end

  it "should allow two users with phone numbers but no emails to be loaded" do
    FactoryGirl.create(:user, email: nil, phone_number: '+19993334444').should be_valid
    FactoryGirl.create(:user, email: nil, phone_number: '+19993334443').should be_valid
    FactoryGirl.build(:user, email: nil, phone_number: nil).should_not be_valid
  end
end

describe User, ".wants_email" do
  it "should select users who want email only or both email and SMS" do
    User.delete_all
    sms_only = FactoryGirl.create(:user, notification_method: 'sms')
    email_only = FactoryGirl.create(:user, notification_method: 'email')
    both = FactoryGirl.create(:user, notification_method: 'both')

    User.wants_email.all.sort.should == [email_only, both].sort
  end
end

describe User, ".wants_sms" do
  it "should select users who want SMS only or both email and SMS" do
    User.delete_all
    sms_only = FactoryGirl.create(:user, notification_method: 'sms')
    email_only = FactoryGirl.create(:user, notification_method: 'email')
    both = FactoryGirl.create(:user, notification_method: 'both')

    User.wants_sms.all.sort.should == [sms_only, both].sort
  end
end

describe User, "default notification method" do
  it "should set the default notification method to 'email'" do
    User.new.notification_method.should == 'email'
  end
end

describe User, "loads personal email" do
  before(:each) do
    @email = 'hi@hi.com'
    @alternate_email = 'there@there.com'
    @leah = FactoryGirl.create(:user, email: @email)
  end

  it "should return nil if fed a bogus email address" do
    @leah.load_personal_email(nil).should == nil
    @leah.reload.email.should == @email
    @leah.overflow_email.should be_blank
  end

  it "should load as primary if primary is blank" do
    @leah.email = ''
    @leah.load_personal_email(@alternate_email)
    @leah.reload.email.should == @alternate_email
    @leah.overflow_email.should be_blank
  end
end

describe User, "finds by either email" do
  before(:each) do
    @leah_email = 'leah@princess.net'
    @leah_personal = 'leah@personal.net'
    @leah = FactoryGirl.create(:user, email: @leah_personal, overflow_email: @leah_email)
    @rice_email = 'rice@princess.net'
    @rice_personal = 'rice@personal.net'
    @rice = FactoryGirl.create(:user, email: @rice_personal, overflow_email: @rice_email)
    @jay_email = 'jay@princess.net'
    @jay_personal = 'jay@personal.net'
    @jay = FactoryGirl.create(:user, email: @jay_personal, overflow_email: @jay_email)
  end

  it "should find by either email" do
    User.find_by_either_email("    " + @leah_email + " ").should == @leah
    User.find_by_either_email(@leah_personal.upcase).should == @leah
    User.find_by_either_email(@jay_email).should == @jay
    User.find_by_either_email(@jay_personal).should == @jay
    User.find_by_either_email(@rice_email).should == @rice
    User.find_by_either_email(@rice_personal).should == @rice
  end
end

describe User, "#reset_tiles" do
  before(:each) do
    @fun = FactoryGirl.create(:demo, name: 'Fun')
    @leah = FactoryGirl.create(:site_admin, name: 'Leah', demo: @fun)
    @rule = FactoryGirl.create(:rule, demo: @fun)
    @tile = FactoryGirl.create(:tile, demo: @fun)
    @rule_trigger = FactoryGirl.create(:rule_trigger, rule: @rule, tile: @tile)
    TileCompletion.count.should == 0
    @act = FactoryGirl.create(:act, rule: @rule, user: @leah, demo: @fun)
    TileCompletion.count.should == 1
    @completion = TileCompletion.first
    Act.count.should == 2 # @act plus the game piece completion act

    # One more act for Leah that should stay around after resetting
    FactoryGirl.create(:act, user: @leah, demo: @fun)

    # Some random stuff that doesn't matter
    FactoryGirl.create(:act)
    FactoryGirl.create(:tile_completion)
  end

  it "resets Leah's tiles for one demo only" do
    TileCompletion.count.should == 2
    Act.count.should == 4
    @leah.reset_tiles(@fun)
    TileCompletion.count.should == 1
    Act.count.should == 3
    TileCompletion.all.map(&:id).should_not include(@completion.id)
    Act.all.map(&:id).should_not include(@act.id)
  end
end

describe User, "add_tickets" do
  it "should use the user's ticket threshold base" do
    @user = FactoryGirl.create(:user, points: 19, ticket_threshold_base: 19)
    @user.tickets.should be_zero

    @user.update_points(@user.demo.ticket_threshold - 1)
    @user.save!
    @user.reload.tickets.should be_zero

    @user.update_points(1)
    @user.save!
    @user.reload.tickets.should == 1

    @user.update_points(@user.demo.ticket_threshold - 1)
    @user.save!
    @user.reload.tickets.should == 1

    @user.update_points(1)
    @user.save!
    @user.reload.tickets.should == 2
  end
end

describe User, "has_balances?" do
  it "should return true for a user in a demo with balances" do
    user = FactoryGirl.create(:user)
    FactoryGirl.create(:balance, demo: user.demo)
    user.should have_balances
  end

  it "should return false for a user without balances" do
    FactoryGirl.create(:user).should_not have_balances
  end
end

describe User, "#flush_tickets_in_board" do
  before do
    @user = FactoryGirl.create(:user, points: 123, tickets: 79)
  end

  context "of the board the user is currently in" do
    it "resets tickets and ticket_threshold base" do
      @user.flush_tickets_in_board(@user.demo_id)

      @user.reload.points.should == 123
      @user.reload.ticket_threshold_base.should == 123
      @user.reload.tickets.should == 0
    end
  end

  context "on a different board than the user is currently in" do
    it "resets tickets and ticket_threshold base on the board membership" do
      other_board = FactoryGirl.create(:demo)
      @user.add_board(other_board)
      @user.demos.should include(other_board)
      @user.demo.should_not == other_board
      board_membership = @user.board_memberships.find_by_demo_id(other_board.id)
      board_membership.update_attributes(points: 456, tickets: 44)

      @user.flush_tickets_in_board(other_board.id)
      @user.reload.points.should == 123
      @user.reload.ticket_threshold_base.should == 0
      @user.reload.tickets.should == 79

      board_membership.reload.points.should == 456
      board_membership.reload.ticket_threshold_base.should == 456
      board_membership.tickets.should == 0
    end
  end
end

describe User, "#not_in_any_paid_boards?" do
  it "returns what you'd think" do
    user = FactoryGirl.create(:user)
    user.not_in_any_paid_boards?.should be_true

    user.demo.update_attributes(is_paid: true)
    user.not_in_any_paid_boards?.should be_false

    user.demo.update_attributes(is_paid: false)
    user.add_board(FactoryGirl.create(:demo, :paid))
    user.not_in_any_paid_boards?.should be_false
  end
end

describe User, "#data_for_mixpanel" do
  it "should include the user's is_test_user flag, normalized to false in case of nil" do
    user1 = FactoryGirl.build(:user, created_at: Time.now)
    user2 = FactoryGirl.build(:user, is_test_user: false, created_at: Time.now)
    user3 = FactoryGirl.build(:user, is_test_user: true, created_at: Time.now)

    user1.data_for_mixpanel[:is_test_user].should == false
    user2.data_for_mixpanel[:is_test_user].should == false
    user3.data_for_mixpanel[:is_test_user].should == true
  end
end
