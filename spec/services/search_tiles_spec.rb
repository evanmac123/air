require 'spec_helper'

describe SearchTiles do
  let(:query) { 'health insurance' }
  let(:demo) { FactoryGirl.create(:demo) }
  let(:organization) { demo.organization }

  let(:service) { SearchTiles.new(query, organization) }

  describe 'initiailzes' do
    it 'sets query' do
      expect(service.query).to eql('health insurance')
    end

    it 'sets organization' do
      expect(service.organization).to eql(organization)
    end

    it 'sets custom_options' do
      expect(service.custom_options).to eql({})
    end
  end

  describe '#run' do
    it 'calls Tile.search with the correct options' do
      Tile.stubs(:search)

      service.tiles

      expect(Tile).to have_received(:search).with(query, service.send(:options))
    end
  end

  describe 'private methods' do
    describe '#formatted_query' do
      context 'user query is blank' do
        it 'formats to *' do
          service = SearchTiles.new('  ', organization)
          expect(service.send(:formatted_query)).to eql('*')
        end
      end
    end

    describe '#options' do
      context 'custom_options is set' do
        it 'merges default options with custom options smartly' do
          service = SearchTiles.new('health insurance', organization, { where: { status: Tile::DRAFT } } )

          expect(service.send(:options)[:where]).to eql({ status: Tile::DRAFT, demo_ids: [demo.id]})
        end
      end
    end

    describe '#default_where' do
      context 'no organization is passed' do
        it 'removes filter on demo_id' do
          service = SearchTiles.new('health insurance', nil)

          expect(service.send(:options)[:where].keys).to_not include(:demo_ids)
        end
      end
    end

    describe '#default_fields' do
      it 'defaults to headline and supporting_content' do
        expect(service.send(:default_fields)).to eql([:header, :supporting_content])
      end
    end
    
    describe '#default_status' do
      it 'defaults to active and archived' do
        expect(service.send(:default_status)).to eql([Tile::ACTIVE, Tile::ARCHIVE])
      end
    end

    describe '#default_demo_ids' do
      context 'organization exists with demo_ids' do
        it 'matches default_demo_ids to org\'s demo_ids' do
          expect(service.send(:default_demo_ids)).to eql([demo.id])
        end
      end
    end

  end
end
