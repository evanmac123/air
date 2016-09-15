require 'spec_helper'

describe TopicBoard do

  it "is invalid without topic and demo" do
    t = FactoryGirl.build(:topic_board)
    expect(t.valid?).to be_false
  end 

  it "is invalid without topic" do
    t = FactoryGirl.build(:topic_board,:only_board)
    expect(t.valid?).to be_false
  end 

  it "is invalid without demo" do
    t = FactoryGirl.build(:topic_board,:only_topic)
    expect(t.valid?).to be_false
  end 

  it "only supports one designated reference_board per topic " do
      board = FactoryGirl.create(:demo)
      board2 = FactoryGirl.create(:demo)
      topic = FactoryGirl.create(:topic, name:"Wellness")
      FactoryGirl.create(:topic_board, is_reference:true, topic: topic, board: board)
      t2 = FactoryGirl.build(:topic_board, is_reference:true, topic: topic, board: board2)
    expect(t2.valid?).to be_false
  end 

  it "allows duplicate topic and board if isrerences  as reference board" do
      board = FactoryGirl.create(:demo)
      topic = FactoryGirl.create(:topic, name:"Wellness")
      FactoryGirl.create(:topic_board, is_reference:true, topic: topic, board: board)
      t2 = FactoryGirl.build(:topic_board, is_reference:false, topic: topic, board: board)
    expect(t2.valid?).to be_true
  end 

  it "allows multiple unrelated reference records" do
      board = FactoryGirl.create(:demo)
      board2 = FactoryGirl.create(:demo)
      topic = FactoryGirl.create(:topic, name:"Retirement")
      topic2 = FactoryGirl.create(:topic, name:"Finance")
      FactoryGirl.create(:topic_board, is_reference:true, topic: topic, board: board)
      t2 = FactoryGirl.build(:topic_board, is_reference:true, topic: topic2, board: board2)
    expect(t2.valid?).to be_true
  end

  it "allows multiple topics to share the same board" do
      board = FactoryGirl.create(:demo)
      topic = FactoryGirl.create(:topic, name:"Retirement")
      topic2 = FactoryGirl.create(:topic, name:"Finance")
      FactoryGirl.create(:topic_board, is_reference:true, topic: topic, board: board)
      t2 = FactoryGirl.build(:topic_board, is_reference:true, topic: topic2, board: board)
    expect(t2.valid?).to be_true
  end

  it "is valid with topic and demo" do
    t = FactoryGirl.create(:topic_board, :valid)
    expect(t.valid?).to be_true
  end


  describe ".reference_board_set" do
    it "lists reference baords" do
      t = FactoryGirl.create(:topic_board, :valid, is_reference:true)
      FactoryGirl.create(:topic_board, :valid)
      expect(TopicBoard.reference_board_set.pluck(:id)).to eq([t.id])
    end
  end
end
