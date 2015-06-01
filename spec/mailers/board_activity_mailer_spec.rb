require "spec_helper"

include TileHelpers
include EmailHelper


describe BoardActivityMailer do
  before(:each) do
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
  end


	describe "#notify" do
		let(:board) {FactoryGirl.create(:demo)}
		let(:user) {FactoryGirl.create(:user)}
		let(:tiles) {[]}
		let(:mail) {BoardActivityMailer.notify(board, user, tiles) }

		it 'renders the subject' do
			expect(mail.subject).to eql('Your Weekly Activity')
		end

		it 'renders the receiver email' do
			expect(mail.to).to eql([user.email])
		end

		it 'renders the sender email' do
			expect(mail.from).to eql(['"play@ourairbo.com"'])
		end

		it 'assigns @name' do
			expect(mail.body.encoded).to match(user.name)
		end

	end
end

