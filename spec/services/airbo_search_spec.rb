require 'spec_helper'

describe AirboSearch do
  let(:query) { 'health insurance' }
  let(:user) { FactoryGirl.create(:client_admin) }
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

  describe '#user_tiles' do
    let(:tile) { FactoryGirl.create(:tile, demo: demo) }
    let(:tile2) { FactoryGirl.create(:tile, demo: demo) }
    let(:tile3) { FactoryGirl.create(:tile, demo: demo) }

    before do
      tile.save!
      tile2.save!
      tile3.save!
    end

    it 'grabs records from elasticsearch and paginates on them' do
      unpaginated_user_tiles = mock("unpaginated_user_tiles")
      unpaginated_user_tiles.stubs(:records).returns(Tile)
      service.stubs(:unpaginated_user_tiles).returns(unpaginated_user_tiles)

      expect(service.user_tiles.count).to eql(2) # page 1
      expect(service.user_tiles(2).count).to eql(1) # page 2
    end
  end

  describe '#explore_tiles' do
    let(:tile) { FactoryGirl.create(:tile, :public) }
    let(:tile2) { FactoryGirl.create(:tile, :public) }
    let(:tile3) { FactoryGirl.create(:tile, :public) }

    before do
      tile.save!
      tile2.save!
      tile3.save!
    end

    it 'grabs records from elasticsearch and paginates on them' do
      unpaginated_explore_tiles = mock("unpaginated_explore_tiles")
      unpaginated_explore_tiles.stubs(:records).returns(Tile.explore)
      service.stubs(:unpaginated_explore_tiles).returns(unpaginated_explore_tiles)

      expect(service.explore_tiles.count).to eql(2) # page 1
      expect(service.explore_tiles(2).count).to eql(1) # page 2
    end
  end

  describe '#organizations' do
    it 'calls Organization.where with the correct filter (based on the explore tiles present)' do
      fake_results = mock("Organization")
      fake_results.stubs(:all).returns([])
      Organization.stubs(:where).returns(fake_results)

      fake_tile = mock("Tile")
      fake_tile.stubs(:demo_id).returns(demo.id)
      service.stubs(:unpaginated_explore_tiles).returns([fake_tile])

      service.organizations

      correct_filter = { id: [demo.organization.id] }

      expect(Organization).to have_received(:where).with(correct_filter)
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

    describe '#default_fields' do
      it 'defaults to headline, supporting_content, and tag_titles' do
        expect(service.send(:default_fields)).to eql(["headline^10", :supporting_content, :tag_titles, :organization])
      end
    end

  end
end
