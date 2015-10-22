require 'spec_helper'

describe Topic do
  it { should have_many(:tile_tags) }

  describe ".make_topics_with_tags" do
    it "should find or create topics and tags" do
      new_topic = "Benefits"
      present_topic = "Compliance"
      new_tags = ["Health Plan Basics", "Health Care Reform"]
      present_tags = ["Sexual Harassment", "Rx Benefits"]
      # create present
      Topic.create(name: "Compliance")
      present_tags.each do |title|
        TileTag.create(title: title)
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
      Topic.find_or_create("Benefits").tile_tags.pluck(:title).should ==
        ["Rx Benefits", "Health Plan Basics"] # order by creation time
      Topic.find_or_create("Compliance").tile_tags.pluck(:title).should ==
        ["Sexual Harassment", "Health Care Reform"]
    end
  end

  describe ".find_or_create" do
    it "should create new topic" do
      Topic.count == 0
      topic = Topic.find_or_create("Good Topic")
      Topic.count == 1
      Topic.first.name == "Good Topic"
    end

    it "should find a topic" do
      old_topic = Topic.create(name: "Good Topic")
      topic = Topic.find_or_create("Good Topic")
      old_topic == topic
    end
  end
end
