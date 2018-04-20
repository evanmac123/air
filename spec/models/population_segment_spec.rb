require 'rails_helper'

RSpec.describe PopulationSegment, type: :model do
  it { is_expected.to belong_to :demo }
  it { is_expected.to have_many :campaigns }
  it { is_expected.to have_many :user_population_segments }
  it { is_expected.to have_many :users }
  it { is_expected.to validate_presence_of :name }
  it { is_expected.to validate_uniqueness_of(:name).case_insensitive.scoped_to(:demo_id) }

  describe "#before_validation" do
    it "calls #strip_whitespace" do
      s = PopulationSegment.new
      s.expects(:strip_whitespace)

      s.valid?
    end
  end

  describe "#strip_whitespace" do
    it "removes whitespace from name" do
      s = PopulationSegment.new(name: "  hey  ")
      s.valid?

      expect(s.name).to eq("hey")
    end
  end
end
