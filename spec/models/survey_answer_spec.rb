require 'spec_helper'

describe SurveyAnswer do
  it {should belong_to :user}
  it {should belong_to :survey_question}
  it {should belong_to :survey_valid_answer}
  it {should have_one(:survey).through(:survey_question)}
end
