require 'spec_helper'

describe SurveyPrompt do
  it {should validate_presence_of :send_time}
  it {should validate_presence_of :text}
  it {should validate_presence_of :survey_id}
  it {should belong_to :survey}
  it {should have_one(:demo).through(:survey)}
end
