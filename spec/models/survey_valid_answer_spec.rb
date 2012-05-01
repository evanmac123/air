require 'spec_helper'

describe SurveyValidAnswer do
  subject {FactoryGirl.create :survey_valid_answer}

  it {should belong_to :survey_question}
  it {should have_one(:survey).through(:survey_question)}
  it {should validate_presence_of :survey_question_id}
  it {should validate_presence_of :value}
  it {should validate_uniqueness_of(:value).scoped_to(:survey_question_id)}
end
