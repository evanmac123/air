require 'spec_helper'

describe Topic do
  it { should have_many(:tile_tags) }

  describe ".make_topics_with_tags" do
    it "should find or create topics and tags" do
      present_tags = ["Sexual Harassment", "Rx Benefits"]
      topic = Topic.create(name: "Compliance")
      present_tags.each do |title|
        TileTag.create(title: title, topic: topic)
      end

      Topic.count.should == 1
      TileTag.count.should == 2
      # make
      full_topics = {
        "Benefits" => ["Health Plan Basics", "Rx Benefits"],
        "Compliance" => ["Health Care Reform", "Sexual Harassment"]
      }
      Topic.make_topics_with_tags full_topics

      Topic.count.should == 2
      TileTag.count.should == 4
      arr1 = ["Rx Benefits", "Health Plan Basics"]
      arr2 = ["Health Care Reform", "Sexual Harassment"]
      expect { arr1 & Topic.find_or_create("Benefits").tile_tags.pluck(:title) == arr1}.to be_true 
      expect {Topic.find_or_create("Compliance").tile_tags.pluck(:title) == arr2}.to be_true
    end
  end

  describe ".find_or_create" do

    it "should find a topic" do
      old_topic = Topic.create(name: "Good Topic")
      topic = Topic.find_or_create("Good Topic")
      old_topic == topic
    end
  end

  describe ".reference_board" do
    it "returns one reference board" do
      board = FactoryGirl.create(:demo)
      topic = FactoryGirl.create(:topic, name:"Wellness")
      FactoryGirl.create(:topic_board, is_reference:true, topic: topic, board: board)
      expect(topic.reference_board.id).to eq(board.id)
    end
  end

  describe ".reference_board" do
    it "returns one reference board" do
      board = FactoryGirl.create(:demo)
      board2 = FactoryGirl.create(:demo)
      topic = FactoryGirl.create(:topic, name:"Wellness")
      FactoryGirl.create(:topic_board, is_reference:true, topic: topic, board: board)
      FactoryGirl.create(:topic_board, topic: topic, board: board2)

      expect(topic.reference_board.id).to eq(board.id)
      expect(topic.boards.pluck(:id).sort).to eq([board.id, board2.id])
    end
  end

  describe ".rearrange" do
    it "should put topic to last position by name" do
      ["Wellness", "Compliance", "Other", "Recruitment"].each{|name| Topic.create(name: name)}
      Topic.rearrange("Other").map(&:name).should == ["Wellness", "Compliance", "Recruitment", "Other"]
    end

    it "should leave topics unchangable if topic with the name is not present" do
      ["Wellness", "Compliance", "Recruitment"].each{|name| Topic.create(name: name)}
      Topic.rearrange("Other").map(&:name).should == ["Wellness", "Compliance", "Recruitment"]
    end
  end
end
