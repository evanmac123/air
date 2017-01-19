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
    it 'calls Tile.search with the correct options (scoped to the current board/demo)' do
      Tile.stubs(:search)

      service.my_tiles

      correct_options = { fields: [:header, :supporting_content, :tag_titles], where: { demo_id: demo.id }, match: :word_start  }

      expect(Tile).to have_received(:search).with(query, correct_options)
    end
  end

  describe '#explore_tiles' do
    it 'calls Tile.search with the "public" options' do
      Tile.stubs(:search)

      service.explore_tiles

      correct_options = { fields: [:header, :supporting_content, :tag_titles], where: { is_public: true, status: [Tile::ACTIVE, Tile::ARCHIVE] }, match: :word_start }

      expect(Tile).to have_received(:search).with(query, correct_options)
    end
  end

  describe '#campaigns' do
    it 'calls Campaign.where with the correct filter (based on the explore tiles present)' do
      fake_results = mock("Campaign")
      fake_results.stubs(:all).returns([])
      Campaign.stubs(:where).returns(fake_results)

      fake_tile = mock("Tile")
      fake_tile.stubs(:demo_id).returns(demo.id)
      service.stubs(:explore_tiles).returns([fake_tile])

      service.campaigns

      correct_filter = { demo_id: [demo.id] }

      expect(Campaign).to have_received(:where).with(correct_filter)
    end
  end

  describe '#organizations' do
    it 'calls Organization.where with the correct filter (based on the explore tiles present)' do
      fake_results = mock("Organization")
      fake_results.stubs(:all).returns([])
      Organization.stubs(:where).returns(fake_results)

      fake_tile = mock("Tile")
      fake_tile.stubs(:demo_id).returns(demo.id)
      service.stubs(:explore_tiles).returns([fake_tile])

      service.organizations

      correct_filter = { id: [demo.organization.id] }

      expect(Organization).to have_received(:where).with(correct_filter)
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
      it 'defaults to headline, supporting_content, and tag_titles' do
        expect(service.send(:default_fields)).to eql([:header, :supporting_content, :tag_titles])
      end
    end
  end
end
