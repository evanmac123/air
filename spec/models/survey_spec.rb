require 'spec_helper'

describe Survey do
  it {should belong_to :demo}
  it {should validate_presence_of :name}
  it {should validate_presence_of :open_at}
  it {should validate_presence_of :close_at}
  it {should have_many :survey_questions}
  it {should have_many :survey_valid_answers}
  it {should have_many :survey_prompts}
  it {should have_many :survey_triggers}

  it "should require the close time to be after the open time" do
    survey = Factory :survey
    survey.should be_valid
    survey.close_at = survey.open_at - 1.second
    survey.should_not be_valid
  end
end
