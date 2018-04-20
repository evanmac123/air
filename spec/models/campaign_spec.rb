require 'spec_helper'

describe Campaign do
  it { is_expected.to belong_to :demo }
  it { is_expected.to have_many :tiles }
  it { is_expected.to validate_presence_of :name }
  it { is_expected.to validate_uniqueness_of(:name).case_insensitive.scoped_to(:demo_id) }

  describe "#before_validation" do
    it "calls #strip_whitespace" do
      c = Campaign.new
      c.expects(:strip_whitespace)

      c.valid?
    end
  end

  describe "#strip_whitespace" do
    it "removes whitespace from name" do
      c = Campaign.new(name: "  hey  ")
      c.valid?

      expect(c.name).to eq("hey")
    end
  end
end
