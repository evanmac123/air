require 'spec_helper'

describe ClientAdminSearch do
  let(:query) { 'health insurance' }
  let(:demo) { FactoryGirl.create(:demo) }

  let(:service) { ClientAdminSearch.new(query, demo) }

  describe 'initiailzes' do
    it 'sets query' do
      expect(service.query).to eql('health insurance')
    end

    it 'sets demo (board)' do
      expect(service.demo).to eql(demo)
    end
  end

  describe '#my_tiles' do
    it 'calls Tile.search with the correct options' do
      Tile.stubs(:search)

      service.my_tiles

      correct_options = { fields: [:header, :supporting_content], where: { demo_id: demo.id }  }

      expect(Tile).to have_received(:search).with(query, correct_options)
    end
  end

  describe '#explore_tiles' do
    it 'calls Tile.search with the "public" options' do
      Tile.stubs(:search)

      service.explore_tiles

      correct_options = { fields: [:header, :supporting_content], where: { is_public: true, status: [Tile::ACTIVE, Tile::ARCHIVE] }  }

      expect(Tile).to have_received(:search).with(query, correct_options)
    end
  end

  describe 'private methods' do
    describe '#formatted_query' do
      context 'user query is blank' do
        it 'formats to *' do
          service = ClientAdminSearch.new('  ', demo)
          expect(service.send(:formatted_query)).to eql('*')
        end
      end
    end

    describe '#default_fields' do
      it 'defaults to headline and supporting_content' do
        expect(service.send(:default_fields)).to eql([:header, :supporting_content])
      end
    end
  end
end
