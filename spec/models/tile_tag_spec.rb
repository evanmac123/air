require 'spec_helper'

describe TileTag do
  let(:tile_tag) { FactoryGirl.build(:tile_tag, topic: nil) }

  it 'is valid' do
    expect(tile_tag).to be_valid
  end

  describe '#set_topic' do
    before { Topic.destroy_all }

    context 'no pre-existing topic and no topics yet exist' do
      it 'generates a topic and assigns it on save' do
        original_count = Topic.count
        
        tile_tag.save!

        expect(tile_tag.topic.name).to eql('Other')
        expect(original_count).to_not eql(Topic.count)
      end
    end

    context '"Other" topic already exists but other topic already exists' do
      let(:topic) { FactoryGirl.build(:topic, name: 'Other') }

      it 'uses the pre-existing Topic' do
        topic.save!
        original_count = Topic.count

        tile_tag.save!

        expect(tile_tag.topic).to eql(topic)
        expect(original_count).to eql(Topic.count)
      end
    end

    context 'topic has been chosen' do
      let(:chosen_topic) { FactoryGirl.create(:topic) }
      let(:tile_tag) { FactoryGirl.build(:tile_tag, topic: chosen_topic) }

      it 'uses the chosen topic' do
        tile_tag.save!

        expect(tile_tag.topic).to eql(chosen_topic)
      end

    end
  end
end
