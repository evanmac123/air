require "spec_helper"

describe ReviewSubmittedTileMailer do
  let!(:demo) {FactoryBot.create :demo, email: "demo@gmail.com"}


  def update_board_memberships
    BoardMembership.all.each do |bm|
      bm.is_client_admin = bm.user.is_client_admin
      bm.save
    end
  end

  describe "#notify_one" do
    before do
      @client_admin = FactoryBot.create :client_admin, email: "ca@airbo.com"
      @tile_sender =  FactoryBot.create :user, email: "user@airbo.com", name: "Tile Sender"
    end

    let(:mail) do
      ReviewSubmittedTileMailer.notify_one  @client_admin.id, demo.id,
                                              @tile_sender.name, @tile_sender.email
    end

    it 'renders the subject' do
      expect(mail.subject).to eql("New Tile Submitted Needs Review")
    end

    it 'renders the receiver email' do
      expect(mail.to).to eql([@client_admin.email])
    end

    it 'renders the sender email' do
      expect(mail.from).to eql([demo.email])
    end

    it 'has correct link' do
      expect(mail.body.encoded).to match(submitted_tile_notifications_url)
    end

    it 'does not mention not having to log in ' do
      expect(mail.body.encoded).not_to match("You won't have to log in.")
    end
  end

  describe "#notify_all" do
    before do
      john   = FactoryBot.create :client_admin, demo: demo, name: 'CA John',   email: 'john@beatles.com'
      paul   = FactoryBot.create :client_admin, demo: demo, name: 'CA Paul',   email: 'paul@beatles.com'
      george = FactoryBot.create :client_admin, demo: demo, name: 'CA George', email: 'george@beatles.com'
      ringo  = FactoryBot.create :client_admin, name: 'CA Ringo',  email: 'ringo@beatles.com'

      @admins = [john, paul, george]
      @tile_sender =  FactoryBot.create :user, demo: demo, email: "user@airbo.com", name: "Tile Sender"

      update_board_memberships
    end

    it 'should be delivered only to client admins of selected demo' do
      mock_delivery = ActionMailer::Base::NullMail.new

      @admins.each do |ca|
        ReviewSubmittedTileMailer.expects(:notify_one).with(ca.id, demo.id, @tile_sender.name, @tile_sender.email).returns(mock_delivery)
      end

      ReviewSubmittedTileMailer.notify_all @tile_sender.id, demo.id
   end
  end
end
