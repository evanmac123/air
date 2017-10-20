require 'spec_helper'

describe Demo do
  it { is_expected.to have_many(:users) }
  it { is_expected.to have_many(:tiles) }
  it { is_expected.to have_many(:locations) }
  it { is_expected.to have_many(:characteristics) }

  it { should_have_valid_mime_type(Demo, :logo_content_type) }

  describe "#customer_status_for_mixpanel" do
    it "returns 'Free' if demo is free" do
      d = Demo.new(customer_status_cd: Demo.customer_statuses[:free])

      expect(d.customer_status_for_mixpanel).to eq("Free")
    end

    it "returns 'Paid' if demo is paid" do
      d = Demo.new(customer_status_cd: Demo.customer_statuses[:paid])

      expect(d.customer_status_for_mixpanel).to eq("Paid")
    end

    it "returns 'Trial' if demo is in a trial" do
      d = Demo.new(customer_status_cd: Demo.customer_statuses[:trial])

      expect(d.customer_status_for_mixpanel).to eq("Trial")
    end
  end

  describe ".paid" do
    it "returns a collection of all paid demos" do
      paid_demos = FactoryGirl.create_list(:demo, 3, customer_status_cd: Demo.customer_statuses[:paid])
      _free_demos = FactoryGirl.create(:demo, customer_status_cd: Demo.customer_statuses[:free])

      expect(Demo.paid).to eq(paid_demos)
    end
  end

  describe ".free" do
    it "returns a collection of all free demos" do
      free_demos = FactoryGirl.create_list(:demo, 3, customer_status_cd: Demo.customer_statuses[:free])
      _paid_demos = FactoryGirl.create(:demo, customer_status_cd: Demo.customer_statuses[:paid])

      expect(Demo.free).to eq(free_demos)
    end
  end

  describe ".free_trial" do
    it "returns a collection of all trial demos" do
      trial_demos = FactoryGirl.create_list(:demo, 3, customer_status_cd: Demo.customer_statuses[:trial])
      _paid_demos = FactoryGirl.create(:demo, customer_status_cd: Demo.customer_statuses[:paid])

      expect(Demo.free_trial).to eq(trial_demos)
    end
  end
end

describe Demo, "#welcome_message" do
  before(:each) do
    @demo = FactoryGirl.create :demo
    @user = FactoryGirl.create :user, :demo => @demo
  end

  context "when the demo has no custom welcome message" do
    before(:each) do
      expect(@demo.custom_welcome_message).to be_nil
    end

    it "should return a reasonable default" do
      expect(@demo.welcome_message(@user)).to eq("You've joined the #{@demo.name} game! @{reply here}")
    end
  end

  context "when the demo has a custom welcome message" do
    before(:each) do
      @demo.custom_welcome_message = "Derp derp! Let's play! You are %{unique_id}, we are %{name}!"
    end

    it "should use that" do
      expect(@demo.welcome_message(@user)).to eq("Derp derp! Let's play! You are #{@user.sms_slug}, we are #{@demo.name}!")
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
    expect(Demo.alphabetical).to eq([@gillette, @red_sox])
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
    expect(demo.print_pending_friendships).to eq(expected)
  end
end

describe Demo, "ticket fields" do
  context "when uses_tickets is set" do
    before(:each) do
      @demo = FactoryGirl.build_stubbed(:demo)
      expect(@demo.uses_tickets).to be_truthy
      @demo.ticket_threshold = nil
    end

    it "should validate that ticket_threshold is set" do
      expect(@demo).not_to be_valid
      expect(@demo.errors.keys).to include(:ticket_threshold)

      @demo.ticket_threshold = 5
      expect(@demo).to be_valid
    end
  end
end

describe Demo, "phone number" do
  it "should normalize itself on save" do
    @demo = FactoryGirl.build(:demo)
    @demo.phone_number = "(617) 555-1212"
    @demo.save
    expect(@demo.reload.phone_number).to eq("+16175551212")
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

    expect(num_tile_completions[tile_1.id]).to eq(1)
    expect(num_tile_completions[tile_3.id]).to eq(3)
    expect(num_tile_completions[tile_5.id]).to eq(5)
    expect(num_tile_completions[tile_7.id]).to eq(7)
    expect(num_tile_completions[tile_9.id]).to eq(9)

    [tile_0, tile_00, tile_000].each { |tile| expect(num_tile_completions[tile.id]).to be_nil }
  end
end

describe Demo, '#create_public_slug!' do
  it "should generate a slug based on the name" do
    d = Demo.create(name: "J.P. Patrick & His 999 Associates, Inc")
    expect(d.reload.public_slug).to eq("jp-patrick-his-999-associates-inc")
  end

  it "should handle duplication nicely" do
    name = 'Attack of the killer tomatoes'
    board_1 = Demo.create(name: name)
    board_2 = Demo.create(name: name + ' board') # an exact duplicate name isn't possible

    expect(board_1.public_slug).to be_present
    expect(board_2.public_slug).to be_present
    expect(board_1.public_slug).not_to eq(board_2.public_slug)
  end

  it "should lop off the word \"board\" if it appears at the end of the slug" do
    d = Demo.create(name: "The Extremely Serious Corporation Board")
    d.create_public_slug!
    expect(d.reload.public_slug).to eq("the-extremely-serious-corporation")
  end
end


describe Demo, 'on create' do
  it 'should set the public slug' do
    d = FactoryGirl.create(:demo)
    expect(d.public_slug).to be_present
  end

  it 'should be public' do
    d = FactoryGirl.create(:demo)
    expect(d.is_public?).to be_truthy
  end
end

describe Demo, '#name_and_org_name' do
  it "returns a string witht he demo name and org name" do
    org = FactoryGirl.build(:organization)
    demo = FactoryGirl.build(:demo, organization: org)

    expect(demo.name_and_org_name).to eq("#{demo.name}, #{org.name}")
  end
end

describe Demo do
  describe "#data_for_dom" do
    it "returns hash of board data for dom access" do
      demo = FactoryGirl.build(:demo, name: "Board", dependent_board_enabled: true)

      data = {
        id: nil,
        name: "Board",
        dependent_board_enabled: true
      }.to_json

      expect(demo.data_for_dom).to eq(data)
    end
  end

  describe "#set_tile_email_draft" do
    it "sets the passed in hash as the values to its tile_email_draft redis key" do
      demo = FactoryGirl.build(:demo)
      params = { a: 1, b: "A string." }

      expect(demo.set_tile_email_draft(params)).to eq("OK")
      expect(JSON.parse(demo.rdb["tile_email_draft"].get).symbolize_keys).to eq(params)
    end
  end

  describe "#clear_tile_email_draft" do
    it "removes any saved draft" do
      demo = FactoryGirl.build(:demo)
      params = { a: 1, b: "A string." }
      demo.set_tile_email_draft(params)

      expect(demo.rdb["tile_email_draft"].get.present?).to eq(true)

      demo.clear_tile_email_draft

      expect(demo.rdb["tile_email_draft"].get.present?).to eq(false)
    end
  end

  describe "#get_tile_email_draft" do
    context "when draft exists" do
      it "returns the draft parsed into a ruby hash" do
        demo = FactoryGirl.build(:demo)
        params = { a: 1, b: "A string." }
        demo.set_tile_email_draft(params)

        expect(demo.get_tile_email_draft).to eq(params)
      end
    end

    context "when there is no draft" do
      it "returns nil" do
        demo = FactoryGirl.build(:demo)

        expect(demo.get_tile_email_draft).to eq(nil)
      end
    end
  end
end
