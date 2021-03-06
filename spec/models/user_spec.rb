require 'spec_helper'

describe User do
  it { should have_one(:demo) }
  it { should have_many (:demos) }
  it { should belong_to(:location) }
  it { should have_many(:acts) }
  it { should have_many(:friendships) }
  it { should have_many(:friends).through(:friendships) }
  it { should have_many(:tile_completions) }
  it { should have_many(:tiles) }
  it { should have_many(:tile_viewings) }
  it { should validate_presence_of(:name).with_message("Please enter a first and last name") }
  it { should have_attached_file(:avatar) }
  it { should validate_attachment_content_type(:avatar).allowing('image/*') }
  it { should validate_presence_of :privacy_level }
end

describe User do
  describe "#tiles_to_complete_in_demo" do
    let(:demo)  { FactoryBot.create(:demo) }
    let!(:active_tiles) { FactoryBot.create_list(:tile, 5, demo: demo, status: Tile::ACTIVE) }
    let!(:draft_tiles) { FactoryBot.create(:tile, demo: demo, status: Tile::DRAFT) }
    let(:user)  { FactoryBot.create(:user, demo: demo) }

    it "returns all active tiles if not completions exist" do
      tiles = user.tiles_to_complete_in_demo
      expect(tiles.count).to eq(5)
      expect(tiles).to eq(demo.tiles.active.ordered_by_position)
    end

    it "returns only active tiles that have not been completed" do
      tile = demo.tiles.active.ordered_by_position[0]

      user.tile_completions.create(tile: tile)

      expect(user.tiles_to_complete_in_demo.count).to eq(4)
      expect(user.tiles_to_complete_in_demo).to eq(demo.tiles.active.ordered_by_position[1..-1])
    end
  end

  describe "#segmented_tiles_for_user" do
    let(:demo)  { FactoryBot.create(:demo) }
    let(:user)  { FactoryBot.create(:user, demo: demo) }
    let!(:population_segment) { FactoryBot.create(:population_segment, demo: demo) }
    let!(:diff_population_segment) { FactoryBot.create(:population_segment, demo: demo) }
    let!(:user_population_segment) { FactoryBot.create(:user_population_segment, user: user, population_segment: population_segment)}
    let!(:campaign) { FactoryBot.create(:campaign, population_segment: population_segment) }
    let!(:diff_campaign) { FactoryBot.create(:campaign, population_segment: diff_population_segment) }
    let!(:unassigned_tiles) { FactoryBot.create_list(:tile, 2, demo: demo, status: Tile::ACTIVE) }
    let!(:campaign_tiles) { FactoryBot.create_list(:tile, 2, demo: demo, status: Tile::ACTIVE, campaign: campaign) }
    let!(:diff_campaign_tiles) { FactoryBot.create_list(:tile, 2, demo: demo, status: Tile::ACTIVE, campaign: diff_campaign) }
    let!(:draft_tiles) { FactoryBot.create(:tile, demo: demo, status: Tile::DRAFT) }

    it "returns all active tiles if not completions exist" do
      tiles = user.segmented_tiles_for_user

      expect(tiles.count).to eq(4)
      expect(tiles).to eq(demo.tiles.segmented_for_user(user).where(status: Tile::ACTIVE))
    end

    it "returns only active tiles that have not been completed" do
      tile = user.segmented_tiles_for_user[0]

      user.tile_completions.create(tile: tile)

      expect(user.tiles_to_complete_in_demo.count).to eq(3)
      expect(user.tiles_to_complete_in_demo.first.id).to eq(demo.tiles.segmented_for_user(user).where(status: Tile::ACTIVE)[1..-1].first.id)
    end
  end

  it "should validate that privacy level is set to a valid value" do
    user = FactoryBot.create :user
    expect(user).to be_valid

    User::PRIVACY_LEVELS.each do |privacy_level|
      user.privacy_level = privacy_level
      expect(user).to be_valid

      user.privacy_level = privacy_level + "foo"
      expect(user).not_to be_valid
    end
  end

  it "should validate uniqueness of phone number when not blank" do
    user1 = FactoryBot.create :user, :phone_number => '+14152613077'
    user2 = FactoryBot.create :user, :phone_number => ''
    user3 = FactoryBot.build :user, :phone_number => '+14152613077'
    user4 = FactoryBot.build :user, :phone_number => ''
    user5 = FactoryBot.build :user, :phone_number => "(415) 261-3077"
    user6 = FactoryBot.build :user, :new_phone_number => FactoryBot.create(:demo, phone_number: "+12125551212").phone_number

    expect(user1).to be_valid
    expect(user2).to be_valid
    expect(user3).not_to be_valid
    expect(user4).to be_valid
    expect(user5).not_to be_valid
    expect(user6).not_to be_valid

    expect(user3.errors[:phone_number]).to eq(["Sorry, but that phone number has already been taken. Need help? Contact support@airbo.com"])
  end

  it 'should validate that there are ten digits in a new phone number, and ignore other characters' do
    expected_error = "Please fill in all ten digits of your mobile number, including the area code"
    bad_numbers = ["415-999-123", "415-867-53009"]
    good_numbers = ["(415) 999-1234", "617-404-8008"]

    bad_numbers.each do |bad_number|
      user = FactoryBot.build :user, new_phone_number: bad_number
      expect(user).not_to be_valid
      expect(user.errors[:new_phone_number]).to include(expected_error)
    end

    good_numbers.each do |good_number|
      user = FactoryBot.build :user, new_phone_number: good_number
      expect(user).to be_valid
    end
  end

  it 'should validate 5-digit zipcode' do
    user = FactoryBot.build :user
    expect(user).to be_valid  # no zipcode is okay

    user.zip_code = 'xxxxx'
    expect(user).not_to be_valid

    user.zip_code = '12345-6789'
    expect(user).not_to be_valid

    user.zip_code = '12345'
    expect(user).to be_valid
  end

  it "should validate uniqueness of SMS slug when not blank" do
    user1 = FactoryBot.create(:claimed_user)
    user2 = FactoryBot.create(:claimed_user)
    user2.sms_slug = user1.sms_slug
    expect(user2).not_to be_valid
  end

  it "should validate that the SMS slug, if not blank, consists of all letters and digits" do
    user = FactoryBot.create :claimed_user
    expect(user).to be_valid

    user.sms_slug = "i rule"
    expect(user).not_to be_valid
    expect(user.errors[:sms_slug]).to eq(["Sorry, the username must consist of letters or digits only."])

    user.sms_slug = "i!rule"
    expect(user).not_to be_valid
    expect(user.errors[:sms_slug]).to eq(["Sorry, the username must consist of letters or digits only."])

    user.sms_slug = "irule23times"
    expect(user).to be_valid
  end

  it "should validate that date of birth, if present, is in the past" do
    Timecop.freeze(Time.current)

    begin
      user = FactoryBot.create :claimed_user
      expect(user).to be_valid

      user.date_of_birth = Date.current
      expect(user).not_to be_valid
      expect(user.errors.full_messages).to include("Date of birth must be in the past")

      user.date_of_birth = Date.yesterday
      expect(user).to be_valid
    ensure
      Timecop.return
    end
  end

  it "should downcase an SMS slug before validation" do
    user1 = FactoryBot.create :user
    user1.update_attributes(:sms_slug => "somedude")

    user2 = FactoryBot.create :claimed_user
    expect(user2).to be_valid

    user2.sms_slug = 'SomeDude'
    expect(user2).not_to be_valid
    expect(user2.errors[:sms_slug]).to eq(["Sorry, that username is already taken."])
    user3 = FactoryBot.create :user
    user3.update_attributes(:sms_slug => "OtherDude")
    expect(user3.reload.sms_slug).to eq("otherdude")
  end

  it "should allow multiple users, each with the same (blank) sms slugs" do
    FactoryBot.create(:user, :sms_slug => '')
    user = FactoryBot.build(:user, :sms_slug => '')
    expect(user).to be_valid
  end

  describe "on create" do
    it "should set their explore_token" do
      user = FactoryBot.create(:user)
      expect(user.explore_token).to be_present
    end
  end

  describe "on destroy" do
    it "should destroy any Friendships where this user is the friend on destroy" do
      user1 = FactoryBot.create(:user)
      user2 = FactoryBot.create(:user)
      Friendship.create!(:user => user1, :friend => user2)

      user2.destroy
      expect(user1.reload.friendships).to be_empty
    end
  end
end

describe User do
  before do
    User.delete_all
  end

  it "should not require a slug if there is no name" do
    # That way, there's only the one error if the name is blank
    a = FactoryBot.build(:user, :name => "")
    expect(a).not_to be_valid
    expect(a.errors[:slug]).to be_empty
    expect(a.errors[:sms_slug]).to be_empty
  end

  it "should create a slug upon validation if there is a name" do
    a = FactoryBot.build(:user, :name => "present")
    expect(a).to be_valid   # Slugs generated before_validation
    expect(a.slug).to eq("present")
    expect(a.sms_slug).to eq("present")
  end

  it "should create slugs when you create" do
    a = FactoryBot.create(:user, :name => "present")
    expect(a.slug).to eq("present")
    expect(a.sms_slug).to eq("present")
  end

  it "should validate the uniqueness of :slug if name is present" do
    a = FactoryBot.build(:user, :name =>"present", :slug => "areallylongstring", :sms_slug => "areallylongstring")
    expect(a).to be_valid
    a.save
    bb = FactoryBot.build(:user, :name =>"present", :slug => "areallylongstring", :sms_slug => "areallylongstring")
    expect(bb).not_to be_valid # since slugs are already present, set_slugs will not be called
    expect(bb.errors[:slug]).to include("has already been taken")
    expect(bb.errors[:sms_slug]).to include("Sorry, that username is already taken.")
  end
end



describe User, "#update_password" do
  context "when called with blank password and confirmation" do
    # We can't just validate_presence_of :password since sometimes a blank
    # password is valid and it's tricky to sum up those cases in one method on
    # User. But #update_password should never let a blank password be set.

    it "should return false and not update" do
      user = FactoryBot.create :user
      user.password = "foobar"
      user.save!

      expect(user.update_password("")).to eq(false)
      expect(user.password).to eq("foobar")
    end
  end
end

describe User, "#invitation_code" do
  before do
    Timecop.freeze("1/1/11") do
      @user     = FactoryBot.create(:user)
      @expected = Digest::SHA1.hexdigest("--#{Time.current.to_f}--#{@user.email}--#{@user.name}--")
    end
  end

  after do
    Timecop.return
  end

  it "should create unique invitation code" do
    expect(@user.invitation_code).to eq(@expected)
  end

  context "when invitation code is not blank" do
    it "should validate uniqueness" do
      user1 = FactoryBot.create(:user)
      user2 = FactoryBot.create(:user)

      expect(user1.invitation_code).not_to be_blank
      expect(user2).to be_valid

      user2.invitation_code = user1.invitation_code
      expect(user2).not_to be_valid
    end
  end
end

describe User, '#set_invitation_code' do
  it "should retry until unique" do
    first_code = "asdasdasdasdasd"
    second_code = "qweqweqweqweqwe"

    user1 = FactoryBot.create(:user)
    user2 = FactoryBot.create(:user)

    user1.update_attributes(invitation_code: first_code)

    Digest::SHA1.stubs(:hexdigest).returns(first_code, second_code)

    user2.set_invitation_code

    expect(user2.invitation_code).to eq(second_code)
    expect(user2).to be_valid
    expect(Digest::SHA1).to have_received(:hexdigest).twice
  end
end

describe User, ".alphabetical" do
  before do
    User.delete_all
    @jobs  = FactoryBot.create(:user, :name => "Steve Jobs")
    @gates = FactoryBot.create(:user, :name => "Bill Gates")
  end

  it "finds all users, sorted alphaetically" do
    expect(User.alphabetical).to eq([@gates, @jobs])
  end
end

describe User, "#invite" do
  subject { FactoryBot.create(:user) }

  context "when added to demo" do
    it { is_expected.not_to be_invited }
  end

  context "when invited" do
    let(:invitation) { stub('invitation') }

    before do
      Mailer.stubs(:invitation => invitation)
      invitation.stubs(:deliver_later)
      subject.invite
    end

    it "sends invitation to user" do
      expect(Mailer).to     have_received(:invitation).with(subject, nil, {})
      expect(invitation).to have_received(:deliver_later)
    end

    it { is_expected.to be_invited }
  end

  context "when no referrer is given" do
    it "should not record a PeerInvitation" do
      expect(PeerInvitation.count).to eq(0)
      subject.invite

      expect(PeerInvitation.count).to eq(0)
    end
  end

  context "when a referrer is given" do
    it "should record a PeerInvitation" do
      other_user = FactoryBot.create(:user)

      expect(PeerInvitation.count).to eq(0)
      subject.invite(other_user)

      expect(PeerInvitation.count).to eq(1)

      invitation = PeerInvitation.first
      expect(invitation.inviter).to eq(other_user)
      expect(invitation.invitee).to eq(subject)
      expect(invitation.demo).to eq(other_user.demo)
    end

    context "and the user already has #{PeerInvitation::CUTOFF} invitations" do
      before(:each) do
        PeerInvitation::CUTOFF.times {FactoryBot.create(:peer_invitation, invitee: subject, demo: subject.demo)}
        expect(subject.reload.peer_invitations_as_invitee.count).to eq(PeerInvitation::CUTOFF)

        other_user = FactoryBot.create(:user)
        subject.invite(other_user)

      end

      it "should not send another invitation email" do
        expect(ActionMailer::Base.deliveries).to be_empty
      end

      it "should not record another PeerInvitation" do
        expect(subject.reload.peer_invitations_as_invitee.count).to eq(PeerInvitation::CUTOFF)
      end
    end
  end
end

describe User, "#slug" do
  context "when John Smith is created" do
    before do
      @first = FactoryBot.create(:user, :name => "John Smith")
    end

    it "has text-only slugs" do
      expect(@first.slug).to eq("johnsmith")
      expect(@first.sms_slug).to eq("johnsmith")
    end

    context "and another John Smith is created" do
      before do
        @second = FactoryBot.create(:user, :name => "John Smith")
      end

      it "has text-and-digit slugs" do
        expect(@second.slug).to match(/^johnsmith\d+$/)
        expect(@second.sms_slug).to match(/^johnsmith\d+$/)
      end

      context "and another John Smith is created" do
        before do
          @third = FactoryBot.create(:user, :name => "John Smith")
        end

        it "has a unique text-and-digit slug" do
          expect(@third.slug).to match(/^johnsmith\d+$/)
          expect(@third.sms_slug).to match(/^johnsmith\d+$/)
          expect(@third.slug).not_to eq(@second.slug)
          expect(@third.sms_slug).not_to eq(@second.sms_slug)
        end
      end
    end
  end
end

describe User, '#generate_simple_claim_code!' do
  before(:each) do
    @first = FactoryBot.create :user
  end

  it "should set the claim code" do
    expect(@first.claim_code).to be_nil
    @first.generate_simple_claim_code!
    expect(@first.claim_code).not_to be_nil
  end

  context "for multiple users with the same name" do
    before(:each) do
      @second = FactoryBot.create :user, :name => @first.name
      @third = FactoryBot.create :user, :name => @first.name
    end

    it "should generate the same claim codes" do
      @first.generate_simple_claim_code!
      @second.generate_simple_claim_code!
      @third.generate_simple_claim_code!

      expect(@first.claim_code).to eq(@second.claim_code)
      expect(@first.claim_code).to eq(@third.claim_code)
    end
  end

  context "for a user with middle names" do
    before(:each) do
      @first = FactoryBot.create :user, :name => "Lyndon Baines Johnson"
      @second = FactoryBot.create :user, :name => "Arthur Andrew Alabama Anderson"
      @third = FactoryBot.create :user, :name => "Elizabeth II, Queen of England"
    end

    it "should use just first and last name" do
      @first.generate_simple_claim_code!
      @second.generate_simple_claim_code!
      @third.generate_simple_claim_code!

      expect(@first.claim_code).to eq('ljohnson')
      expect(@second.claim_code).to eq('aanderson')
      expect(@third.claim_code).to eq('eengland')
    end
  end
end

describe User, '#generate_unique_claim_code!' do
  before(:each) do
    @first = FactoryBot.create :user
  end

  it "should set the claim code" do
    expect(@first.claim_code).to be_nil
    @first.generate_unique_claim_code!
    expect(@first.claim_code).not_to be_nil
  end

  context "for multiple users with the same name" do
    before(:each) do
      @second = FactoryBot.create :user, :name => @first.name
      @third = FactoryBot.create :user, :name => @first.name
    end

    it "should generate unique claim codes" do
      @first.generate_unique_claim_code!
      @second.generate_unique_claim_code!
      @third.generate_unique_claim_code!

      expect(@first.claim_code).not_to eq(@second.claim_code)
      expect(@first.claim_code).not_to eq(@third.claim_code)
      expect(@first.claim_code).not_to eq(@third.claim_code)
    end
  end
end

describe User, "on create" do
  it "should create an associated segmentation info record in mongo" do
    @user = FactoryBot.create :user


    expect(@user.segmentation_data).to be_present
  end
end

describe User, "on save" do
  it "should downcase email" do
    @user = FactoryBot.build(:user, :email => 'YELLING_GUY@Uppercase.cOm')
    @user.save!
    expect(@user.reload.email).to eq('yelling_guy@uppercase.com')
  end

  describe 'spousal relationship synchronization' do
    let(:member) { FactoryBot.create :user }

    describe 'on create' do
      it 'should not link spouse if not specfied' do
        user = FactoryBot.create :user
        expect(member.reload.spouse_id).to be_nil
      end

      it 'should link spouse if specfied' do
        user = FactoryBot.create :user, spouse_id: member.id
        expect(member.reload.spouse_id).to eq(user.id)
      end
    end

    describe 'on update' do
      let(:user) { FactoryBot.create :user }

      it 'should not link spouse if other field updated' do
        user.update_attribute :name, "Fred Flintstone"
        expect(member.reload.spouse_id).to be_nil
      end

      it 'should link spouse if specfied' do
        expect(member.reload.spouse_id).to be_nil

        user.update_attribute :spouse_id, member.id
        expect(member.reload.spouse_id).to eq(user.id)
      end

      it 'should unlink spouse if nullified' do
        user = FactoryBot.create :user, spouse_id: member.id
        expect(member.reload.spouse_id).to eq(user.id)

        user.update_attribute :spouse_id, nil
        expect(member.reload.spouse_id).to be_nil
      end
    end
  end

  it "should parse characteristics according to the datatypes" do
    user = FactoryBot.build :user

    discrete_characteristic = FactoryBot.create :characteristic, :datatype => Characteristic::DiscreteType, :allowed_values => %w(foo bar baz)
    number_characteristic = FactoryBot.create :characteristic, :datatype => Characteristic::NumberType
    date_characteristic = FactoryBot.create :characteristic, :datatype => Characteristic::DateType
    boolean_characteristic = FactoryBot.create :characteristic, :datatype => Characteristic::BooleanType

    user.characteristics = {
      discrete_characteristic.id => 'foo',
      number_characteristic.id   => '27.3',
      date_characteristic.id     => Chronic.parse("March 1, 2009").to_s,
      boolean_characteristic.id  => '1'
    }

    user.save!
    user.reload

    expect(user.characteristics[discrete_characteristic.id]).to eq('foo')
    expect(user.characteristics[number_characteristic.id]).to eq(27.3)
    expect(user.characteristics[date_characteristic.id]).to eq(Chronic.parse("March 1, 2009").to_date)
    expect(user.characteristics[boolean_characteristic.id]).to eq(true)
  end

  def check_for_segmentation_update(field_name, old_value, new_value, expected_values=[])
    expected_old_value = expected_values.first || old_value
    expected_new_value = expected_values.last || new_value

    user = FactoryBot.create(:user, field_name => old_value)

    expect(user.segmentation_data[field_name]).to eq(expected_old_value)

    user.update_attributes(field_name => new_value)

    expect(user.segmentation_data.reload.send(field_name)).to eq(expected_new_value)
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
    user = FactoryBot.create(:user)
    characteristic = FactoryBot.create(:characteristic, :allowed_values => %w(foo bar baz))

    expect(user.segmentation_data.characteristics).to eq({})

    user.characteristics = {characteristic.id => 'foo'}
    user.save

    expect(user.segmentation_data.characteristics).to eq({characteristic.id => 'foo'}.stringify_keys)
  end

  it "should sync to mongo when a user is added to a board" do
    user = FactoryBot.create(:user)
    first_demo = user.demo
    second_demo = FactoryBot.create(:demo)


    expect(user.segmentation_data.demo_ids).to eq([first_demo.id])

    user.add_board(second_demo)

    expect(user.segmentation_data.demo_ids.sort).to eq([first_demo.id, second_demo.id].sort)
  end

  it "should sync to mongo when a user acts" do
    user = FactoryBot.create :user

    expect(user.segmentation_data.last_acted_at).to be_nil
    act = FactoryBot.create(:act, user: user)

    now = Time.current
    expect(user.segmentation_data.last_acted_at).not_to be_nil
  end

  it "should sync to mongo when accepted_invitation_at is changed, updating the value of claimed too" do
    user = FactoryBot.create :user

    expect(user.segmentation_data.accepted_invitation_at).to be_nil
    expect(user.segmentation_data.claimed).to be_falsey

    accept_time = Chronic.parse("May 1, 2012, 3:00 PM")
    user.accepted_invitation_at = accept_time
    user.save!

    expect(user.segmentation_data.accepted_invitation_at).to eq(accept_time.utc)
    user.segmentation_data.claimed is_expected.to be_truthy
  end

  it "should sync to mongo whether or not the user has a phone number on record" do
    user = FactoryBot.create :user

    expect(user.segmentation_data.has_phone_number).to be_falsey

    user.phone_number = "+14155551212"
    user.save!

    expect(user.segmentation_data.has_phone_number).to be_truthy

    user.phone_number = ""
    user.save!

    expect(user.segmentation_data.has_phone_number).to be_falsey
  end
end

describe User, "on destroy" do
  it "should destroy the associated mongo data" do
    user = FactoryBot.create :user

    expect(User::SegmentationData.where(:ar_id => user.id).count).to eq(1)

    user.destroy

    expect(User::SegmentationData.where(:ar_id => user.id).count).to eq(0)
  end
end

describe User, "#move_to_new_demo" do
  before(:each) do
    @user = FactoryBot.create :user
    @new_demo = FactoryBot.create :demo
  end

  context "when the user belongs to the new demo" do
    before do
      @user.add_board @new_demo
    end

    it "should set that as their current demo" do
      @user.move_to_new_demo(@new_demo)
      expect(@user.reload.demo).to eq(@new_demo)
    end

    it "should leave them with one current board" do
      @user.move_to_new_demo(@new_demo)
      expect(@user.board_memberships.where(is_current: true).size).to eq(1)
    end

    it "should keep the value of their board-specific fields consistent with the BoardMembership corresponding to the board they move into" do
      original_demo = @user.demo
      original_location = FactoryBot.create(:location, demo: original_demo)
      @user.is_client_admin = true
      @user.points = 43
      @user.ticket_threshold_base = 21
      @user.tickets = 1
      @user.location = original_location
      @user.save

      @user.move_to_new_demo @new_demo
      expect(@user.reload.is_client_admin).to be_falsey
      expect(@user.reload.points).to eq(0)
      expect(@user.reload.ticket_threshold_base).to eq(0)
      expect(@user.reload.tickets).to eq(0)
      expect(@user.reload.location).to be_nil

      @user.move_to_new_demo original_demo
      expect(@user.reload.is_client_admin).to be_truthy
      expect(@user.reload.points).to eq(43)
      expect(@user.reload.ticket_threshold_base).to eq(21)
      expect(@user.reload.tickets).to eq(1)
      expect(@user.reload.location).to eq(original_location)
    end
  end

  context "when the user does not belong to that demo" do
    before do
      expect(@user.demos).not_to include(@new_demo)
    end

    it "should leave them unmoved" do
      @user.move_to_new_demo(@new_demo)
      expect(@user.reload.demo).not_to eq(@new_demo)
    end

    it "should leave them with one current board" do
      @user.move_to_new_demo(@new_demo)
      expect(@user.board_memberships.where(is_current: true).size).to eq(1)
    end

    context "but is a site admin" do
      before do
        @user.is_site_admin = true
        @user.save!
      end

      it "adds 'em and moves them in" do
        @user.move_to_new_demo(@new_demo)
        expect(@user.reload.demo).to eq(@new_demo)
        expect(@user.demos.size).to eq(2)
      end

      it "should leave them with one current board" do
        @user.move_to_new_demo(@new_demo)
        expect(@user.board_memberships.where(is_current: true).size).to eq(1)
      end
    end
  end
end

describe User, "#add_board" do
  it "should be idempotent, i.e. not create redundant BoardMemberships if called more than once with the same arguments" do
    user = FactoryBot.create(:user)
    expect(user.board_memberships.length).to eq(1)

    board = FactoryBot.create(:demo)

    user.add_board(board)
    user.add_board(board)

    expect(user.board_memberships.length).to eq(2)
    expect(user.board_memberships.where(demo_id: board.id).length).to eq(1)
  end
end

describe "#mark_as_claimed" do
  before(:each) do
    @user = FactoryBot.create :user
    Timecop.freeze(1)
  end

  after(:each) do
    Timecop.return
  end

  context "when called with a phone number" do
    it "should set the user's accepted_invitation_at timestamp" do
      expect(@user.accepted_invitation_at).to be_nil
      @user.mark_as_claimed(:phone_number => '+14158675309')
      expect(@user.reload.accepted_invitation_at.to_s).to eq(ActiveSupport::TimeZone['Eastern Time (US & Canada)'].now.to_s)
    end
  end

  context "when called with an email address" do
    it "should set the user's accepted_invitation_at timestamp" do
      expect(@user.accepted_invitation_at).to be_nil
      @user.mark_as_claimed(:email => 'bob@gmail.com')
      expect(@user.reload.accepted_invitation_at.to_s).to eq(ActiveSupport::TimeZone['Eastern Time (US & Canada)'].now.to_s)
    end
  end
end

describe User do
  describe "#generate_new_phone_validation_token" do
    it "should generate a token" do
      user = FactoryBot.create(:user)
      user.generate_new_phone_validation_token
      expect(user.new_phone_validation.length).to eq(6)
    end
  end

  describe "#send_new_phone_validation_token" do
    it "asks SmsSenderJob to send a message in the background" do
      user = FactoryBot.create(:user, :email => "a@a.com")
      token = user.generate_new_phone_validation_token
      user.new_phone_number = "3333333333"

      SmsSenderJob.expects(:perform_now).with(
        to_number: user.new_phone_number,
        body: "Your code to verify this phone with Airbo is #{token}."
      )

      user.send_new_phone_validation_token
    end
  end
end

describe User do
  describe "Privacy Settings" do
    it "should allow anyone to view the activity of a user whose privacy status is 'everybody'" do
      follower = FactoryBot.create :user
      artist = FactoryBot.create(:user, :privacy_level => "everybody")
      expect(follower.can_see_activity_of(artist)).to eq(true)
    end
  end
end

describe User, "#befriend" do
  before(:each) do
    @demo = FactoryBot.create(:demo, :name => "It's just a game")
    @left_user = FactoryBot.create(:claimed_user, :name => "Lefty Loosey", :demo => @demo)
    @right_user = FactoryBot.create(:claimed_user, :name => "Righty Tighty", :demo => @demo)
  end

  it "should create two friendships, one initiated and one pending" do
    # Befriend
    @left_user.befriend(@right_user)
    # Verify two friendships created, one initiated--one pending
    first_friendship_array = Friendship.where(:user_id => @left_user.id, :friend_id => @right_user.id)
    expect(first_friendship_array.length).to eq(1)
    first_friendship = first_friendship_array.first
    expect(first_friendship.state).to eq("initiated")
    second_friendship_array = Friendship.where(:user_id => @right_user.id, :friend_id => @left_user.id)
    expect(second_friendship_array.length).to eq(1)
    second_friendship = second_friendship_array.first
    expect(second_friendship.state).to eq("pending")
  end

  it "accepting friendship should make both frienships show up accepted" do
    # Befriend
    @left_user.befriend(@right_user)
    # Verify two friendships created, one initiated--one pending
    initiated_friendship = Friendship.where(:user_id => @left_user.id, :friend_id => @right_user.id).first
    pending_friendship = Friendship.where(:user_id => @right_user.id, :friend_id => @left_user.id).first
    initiated_friendship.accept
    expect(initiated_friendship.reload.state).to eq("accepted")
    expect(pending_friendship.reload.state).to eq("accepted")
  end

  it "each shows up as each other friend using the .friends construct" do
    # Befriend
    @left_user.befriend(@right_user)

    expect(@left_user.initiated_friends.length).to eq(1)
    expect(@right_user.initiated_friends).to be_empty
    expect(@right_user.pending_friends.length).to eq(1)
    expect(@left_user.pending_friends).to be_empty
  end

  it "each shows up as each other friend using the .friends construct" do
    # Befriend
    @left_user.befriend(@right_user)
    initiated_friendship = Friendship.where(:user_id => @left_user.id, :friend_id => @right_user.id).first
    initiated_friendship.accept
    # Should be no more pending friends
    expect(@left_user.pending_friends).to be_empty
    expect(@right_user.pending_friends).to be_empty
    # Each should have one real friend
    expect(@left_user.friends.length).to eq(1)
    expect(@right_user.friends.length).to eq(1)
  end
end

describe User do
  it "should not allow any duplicate email addresses across 'email' or 'overflow_email'" do
    first_email = '123@hi.com'
    second_email = '456@hi.com'
    third_email = 'something_crafty@sexy.com'
    FactoryBot.create(:user, email: first_email, overflow_email: second_email)
    @user2 = FactoryBot.build(:user, name: 'henry')
    expect(@user2).to be_valid
    @user2.email = first_email
    expect(@user2).not_to be_valid
    @user2.email = second_email
    expect(@user2).not_to be_valid
    @user2.email = 'way@different.com'
    expect(@user2).to be_valid
    @user2.overflow_email = first_email
    expect(@user2).not_to be_valid
    @user2.overflow_email = second_email
    expect(@user2).not_to be_valid
    @user10 = FactoryBot.build(:user, email: third_email, overflow_email: third_email)
    expect(@user10).not_to be_valid
  end
end

describe User, "notification preferences" do
  before do
    @demo = FactoryBot.create(:demo)
    @sms_only = FactoryBot.create(:user, demo: @demo)
    @sms_only.board_memberships.update_all(notification_pref_cd: BoardMembership.notification_prefs[:text_message])

    @email_only = FactoryBot.create(:user, demo: @demo)
    @email_only.board_memberships.update_all(notification_pref_cd: BoardMembership.notification_prefs[:email])

    @both = FactoryBot.create(:user, demo: @demo)
    @both.board_memberships.update_all(notification_pref_cd: BoardMembership.notification_prefs[:both])
  end

  describe ".wants_email" do
    it "should select users who want email only or both email and SMS" do
      user_ids_that_want_email = User.wants_email(user_ids: User.pluck(:id), demo_id: @demo.id).pluck(:id)

      expect(user_ids_that_want_email.sort).to eq([@email_only.id, @both.id].sort)
    end
  end

  describe ".wants_sms" do
    it "should select users who want SMS only or both email and SMS" do
      user_ids_that_want_sms = User.wants_sms(user_ids: User.pluck(:id), demo_id: @demo.id).pluck(:id)

      expect(user_ids_that_want_sms.sort).to eq([@sms_only.id, @both.id].sort)
    end
  end
end


describe User, "default notification method" do
  it "should set the default notification method to 'email'" do
    expect(User.new.notification_method).to eq('email')
  end
end

describe User, "loads personal email" do
  before(:each) do
    @email = 'hi@hi.com'
    @alternate_email = 'there@there.com'
    @leah = FactoryBot.create(:user, email: @email)
  end

  it "should return nil if fed a bogus email address" do
    expect(@leah.load_personal_email(nil)).to eq(nil)
    expect(@leah.reload.email).to eq(@email)
    expect(@leah.overflow_email).to be_blank
  end

  it "should load as primary if primary is blank" do
    @leah.email = ''
    @leah.load_personal_email(@alternate_email)
    expect(@leah.reload.email).to eq(@alternate_email)
    expect(@leah.overflow_email).to be_blank
  end
end

describe User, "finds by either email" do
  before(:each) do
    @leah_email = 'leah@princess.net'
    @leah_personal = 'leah@personal.net'
    @leah = FactoryBot.create(:user, email: @leah_personal, overflow_email: @leah_email)
    @rice_email = 'rice@princess.net'
    @rice_personal = 'rice@personal.net'
    @rice = FactoryBot.create(:user, email: @rice_personal, overflow_email: @rice_email)
    @jay_email = 'jay@princess.net'
    @jay_personal = 'jay@personal.net'
    @jay = FactoryBot.create(:user, email: @jay_personal, overflow_email: @jay_email)
  end

  it "should find by either email" do
    expect(User.find_by_either_email("    " + @leah_email + " ")).to eq(@leah)
    expect(User.find_by_either_email(@leah_personal.upcase)).to eq(@leah)
    expect(User.find_by_either_email(@jay_email)).to eq(@jay)
    expect(User.find_by_either_email(@jay_personal)).to eq(@jay)
    expect(User.find_by_either_email(@rice_email)).to eq(@rice)
    expect(User.find_by_either_email(@rice_personal)).to eq(@rice)
  end
end

describe User, "#reset_tiles" do
  it "resets Leah's tiles for one demo only" do
    demo = FactoryBot.create(:demo)
    user = FactoryBot.create(:user, demo: demo)
    tile = FactoryBot.create(:tile, demo: demo)
    completion = TileCompletion.create(user: user, tile: tile)

    # A completion by someone else
    FactoryBot.create(:tile_completion)

    expect(TileCompletion.count).to eq(2)

    user.reset_tiles(demo)
    expect(TileCompletion.count).to eq(1)
    expect(TileCompletion.where(id: completion.id)).to be_empty
  end
end

describe User, "add_tickets" do
  it "should use the user's ticket threshold base" do
    @user = FactoryBot.create(:user, points: 19, ticket_threshold_base: 19)
    expect(@user.tickets).to be_zero

    @user.update_points(@user.demo.ticket_threshold - 1)
    @user.save!
    expect(@user.reload.tickets).to be_zero

    @user.update_points(1)
    @user.save!
    expect(@user.reload.tickets).to eq(1)

    @user.update_points(@user.demo.ticket_threshold - 1)
    @user.save!
    expect(@user.reload.tickets).to eq(1)

    @user.update_points(1)
    @user.save!
    expect(@user.reload.tickets).to eq(2)
  end
end

describe User, "#not_in_any_paid_or_trial_boards?" do
  it "returns what you'd think" do
    user = FactoryBot.create(:user)
    expect(user.not_in_any_paid_or_trial_boards?).to be_truthy

    user.demo.update_attributes(customer_status_cd: Demo.customer_statuses[:paid])
    expect(user.not_in_any_paid_or_trial_boards?).to be_falsey

    user.demo.update_attributes(customer_status_cd: Demo.customer_statuses[:trial])
    expect(user.not_in_any_paid_or_trial_boards?).to be_falsey

    user.demo.update_attributes(customer_status_cd: Demo.customer_statuses[:free])
    user.add_board(FactoryBot.create(:demo, :paid))
    expect(user.not_in_any_paid_or_trial_boards?).to be_falsey
  end
end

describe User, "#data_for_mixpanel" do

  it "should include a user's email address only if they're a client admin" do
    peon = FactoryBot.build(:user, email: 'peon@example.com', created_at: Time.current)
    client_admin = FactoryBot.build(:client_admin, email: 'ca@example.com', created_at: Time.current)

    expect(peon.data_for_mixpanel[:email]).to be_nil
    expect(client_admin.data_for_mixpanel[:email]).to eq(client_admin.email)
  end
end

describe User, "#email_for_vendor" do
  it "should return nil for end users" do
    end_user = FactoryBot.build(:user, email: 'end_user@example.com')

    expect(end_user.email_for_vendor).to eq(nil)
  end

  it "should return email for client admin" do
    client_admin = FactoryBot.build(:client_admin, email: 'ca@example.com')

    expect(client_admin.email_for_vendor).to eq(client_admin.email)
  end
end

describe User, ".paid_client_admin" do
  it "should return users who have a client admin board membership in a demo that is paid" do
    paid_demo = FactoryBot.create(:demo, name: "Paid", customer_status_cd: Demo.customer_statuses[:paid])
    unpaid_demo = FactoryBot.create(:demo, name: "Unpaid", customer_status_cd: Demo.customer_statuses[:free])

    paid_client_admin = FactoryBot.create(:user, name: "Paid Ca")
    paid_client_admin.board_memberships.create(demo: paid_demo, is_client_admin: true)

    unpaid_client_admin = FactoryBot.create(:user, name: "Unpaid Ca")
    unpaid_client_admin.board_memberships.create(demo: paid_demo, is_client_admin: false)
    unpaid_client_admin.board_memberships.create(demo: unpaid_demo, is_client_admin: false)

    expect(User.paid_client_admin.pluck(:id)).to eq([paid_client_admin.id])
  end
end

describe User do
  describe "#first_name" do
    it "returns the first name" do
      u = User.new(name: "Test Wyatt Hess")

      expect(u.first_name).to eq("Test")
    end
  end

  describe "#last_name" do
    it "returns multiple last names if present" do
      u = User.new(name: "Test Wyatt Hess")

      expect(u.last_name).to eq("Wyatt Hess")
    end

    it "returns the last name" do
      u = User.new(name: "Test Wyatt")

      expect(u.last_name).to eq("Wyatt")
    end

    it "titleizes the name(s)" do
      u = User.new(name: "Test wyatt hess")

      expect(u.last_name).to eq("Wyatt Hess")
    end
  end

  describe "#mixpanel_data_for_profile" do
    it "returns correct data to create mixpanel user profiles" do
      fake_org = OpenStruct.new({
        customer_status: :paid,
        company_size: :smb,
        name: "Org Name",
        internal?: false
      })

      user = User.new(name: "test user", email: "email@example.com")

      user.expects(:organization).returns(fake_org).at_most(4)

      data = {
        "$email" => "email@example.com",
        "$first_name" => "Test",
        "$last_name" => "User",
        "customer_status" => :paid,
        "org_size" => :smb,
        "org_name" => "Org Name",
        "internal" => false
      }

      expect(user.mixpanel_data_for_profile).to eq(data)
    end
  end
end
