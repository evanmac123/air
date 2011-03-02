require 'spec_helper'

describe User do
  before do
    Factory(:user)
  end

  it { should belong_to(:demo) }
  it { should have_many(:acts) }
  it { should have_many(:friendships) }
  it { should have_many(:friends).through(:friendships) }

  it { should validate_uniqueness_of(:slug) }
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

    it "should set that user's phone number and clear their claim code" do
      @user.phone_number.should be_blank
      @user.claim_code.should_not be_blank

      User.claim_account(@from, @claim_code)

      @user.reload
      @user.phone_number.should == @from
      @user.claim_code.should be_nil
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

describe User, "#send_welcome_sms" do
  subject { Factory(:user) }
  let(:phone_number) { "(508) 740-7520" }

  before do
    Twilio::SMS.stubs(:create)
    subject.join_game(phone_number)
  end

  it "normalizes and saves the phone number" do
    subject.reload.phone_number.should == "+15087407520"
  end

  it "sends welcome SMS" do
    Twilio::SMS.should have_received(:create)
  end
end

describe User, "#slug" do
  context "when John Smith is created" do
    before do
      @first = Factory(:user, :name => "John Smith")
    end

    it "has a text-only slug" do
      @first.slug.should == "John-Smith"
    end

    context "and another John Smith is created" do
      before do
        @second = Factory(:user, :name => "John Smith")
      end

      it "has a text-and-digit slug" do
        @second.slug.should match(/^John-Smith-\d+$/)
      end

      context "and another John Smith is created" do
        before do
          @third = Factory(:user, :name => "John Smith")
        end

        it "has a unique text-and-digit slug" do
          @third.slug.should match(/^John-Smith-\d+$/)
          @third.slug.should_not == @second.slug
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

describe User, "#ranking" do
  before(:each) do
    @demo = Factory :demo
    10.downto(6) {|i| Factory :user, :points => i, :demo => @demo}
    1.upto(4) {|i| Factory :user, :points => i, :demo => @demo}
    @user = Factory :user, :points => 5, :demo => @demo
  end

  context "when a user is created" do
    it "should set their ranking appropriately" do
      users_by_points = @demo.users.order('points DESC').all
      users_by_points.map(&:ranking).should == [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

      @user.ranking.should == 6
    end
  end

  context "when a user gains points" do
    it "should reset their ranking" do
      @user.update_points(3)
      @user.reload.ranking.should == 3
    end

    it "should reset the ranking of all users who are now below them but weren't before" do
      @twin = Factory :user, :points => 5, :demo => @demo
      @twin.ranking.should == @user.ranking

      @user.update_points(3)

      users_by_points = @demo.users.order('points DESC').all
      users_by_points.map(&:ranking).should == [1, 2, 3, 3, 5, 6, 7, 8, 9, 10, 11]
    end

    it "should work when breaking ties" do
      User.delete_all
      @first = Factory :user, :points => 10, :demo => @demo
      @second = Factory :user, :points => 10, :demo => @demo
      @third = Factory :user, :points => 10, :demo => @demo

      @first.reload.ranking.should == @second.reload.ranking
      @first.reload.ranking.should == @third.reload.ranking

      @first.update_points(1)
      @first.reload.ranking.should == 1
      @second.reload.ranking.should == 2
      @third.reload.ranking.should == 2
    end
  end
end

describe User, "on save" do
  it "should downcase email" do
    @user = Factory.build(:user, :email => 'YELLING_GUY@Uppercase.cOm')
    @user.save!
    @user.reload.email.should == 'yelling_guy@uppercase.com'
  end
end
