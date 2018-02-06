require 'spec_helper'

describe AirboSearch, search: true do
  let(:query) { 'health insurance' }
  let(:user) { FactoryBot.create(:client_admin) }
  let(:demo) { user.demos.first }

  let(:options) { { per_page: 2 } } # low per_page to make testing easier
  let(:service) { AirboSearch.new(query, user, options) }

  describe 'initiailzes' do
    it 'sets query' do
      expect(service.query).to eql('health insurance')
    end

    it 'sets demo (board)' do
      expect(service.demo).to eql(demo)
    end

    it 'sets options' do
      expect(service.options).to eql(options)
    end
  end

  describe 'private methods' do
    describe '#formatted_query' do
      context 'user query is blank' do
        it 'formats to *' do
          service = AirboSearch.new('  ', user, {})
          expect(service.send(:formatted_query)).to eql('*')
        end
      end
    end
  end
end
