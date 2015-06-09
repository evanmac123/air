require "spec_helper"

describe SuggestedTileToReviewMailer do
  let!(:demo) {FactoryGirl.create :demo}


  def update_board_memberships
    BoardMembership.all.each do |bm|
      bm.is_client_admin = bm.user.is_client_admin
      bm.save
    end
  end

  describe "#notify_one" do
    before do
      @client_admin = FactoryGirl.create :client_admin, email: "ca@airbo.com"
      @tile_sender =  FactoryGirl.create :user, email: "user@airbo.com", name: "Tile Sender"
    end

    let(:mail) do 
      SuggestedTileToReviewMailer.notify_one  @client_admin.id, demo.id, 
                                              @tile_sender.name, @tile_sender.email
    end

    it 'renders the subject' do
      expect(mail.subject).to eql("New Tile Suggested To Review")
    end

    it 'renders the receiver email' do
      expect(mail.to).to eql([@client_admin.email])
    end

    it 'renders the sender email' do
      expect(mail.from).to eql(["suggestion_box@airbo.com"])
    end

    it 'has correct CTA text' do
      expect(mail.body.encoded).to match("#{@tile_sender.name} #{@tile_sender.email} has submitted a Tile for your review.")
    end

    it 'does not mention not having to log in ' do
      expect(mail.body.encoded).not_to match("You won't have to log in.")
    end
  end

  describe "#notify_all" do
    before do
      john   = FactoryGirl.create :client_admin, demo: demo, name: 'CA John',   email: 'john@beatles.com'
      paul   = FactoryGirl.create :client_admin, demo: demo, name: 'CA Paul',   email: 'paul@beatles.com'
      george = FactoryGirl.create :client_admin, demo: demo, name: 'CA George', email: 'george@beatles.com'
      ringo  = FactoryGirl.create :client_admin, name: 'CA Ringo',  email: 'ringo@beatles.com'

      @admins = [john, paul, george]
      @tile_sender =  FactoryGirl.create :user, demo: demo, email: "user@airbo.com", name: "Tile Sender"

      update_board_memberships
    end

    it 'should be delivered only to client admins of selected demo' do
      object = mock('delay')
      SuggestedTileToReviewMailer.stubs(:delay).returns(object)

      object.expects(:notify_one).at_most(3)
      @admins.each do |ca|
        object.expects(:notify_one).with(ca.id, demo.id, @tile_sender.name, @tile_sender.email)
      end

      SuggestedTileToReviewMailer.notify_all @tile_sender.id, demo.id
   end
  end
end
