require 'spec_helper'

describe SurveyQuestion do
  subject {FactoryGirl.create(:survey_question)}

  it {should have_many :survey_valid_answers}
  it {should validate_presence_of :text}
  it {should validate_presence_of :survey_id}
  it {should validate_presence_of :index}
  it {should belong_to :survey}
  it {should validate_uniqueness_of(:index).scoped_to(:survey_id)}
end
