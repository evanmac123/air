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
